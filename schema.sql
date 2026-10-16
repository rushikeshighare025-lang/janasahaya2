-- JanSahay database schema (PostgreSQL 13+). Follows the ER diagram, plus the columns the app needs
-- (login, profile flags, multilingual scheme text, rule levels, uploaded-file details).
-- Safe to run more than once.

CREATE TABLE IF NOT EXISTS citizens (
  citizen_id        SERIAL PRIMARY KEY,
  name              VARCHAR(100) NOT NULL,
  mobile            VARCHAR(15)  NOT NULL UNIQUE,              -- login id
  password_hash     TEXT         NOT NULL,                     -- bcrypt hash, never the password
  age               INT CHECK (age BETWEEN 0 AND 120),
  gender            VARCHAR(20) CHECK (gender IN ('m','f','o')),
  income            DECIMAL(12,2),                             -- upper bound of the chosen income band
  income_band       SMALLINT CHECK (income_band BETWEEN 0 AND 4),
  occupation        VARCHAR(100),
  state             VARCHAR(100),
  district          VARCHAR(100),
  category          VARCHAR(50),                               -- General / OBC / SC / ST
  language          VARCHAR(50) DEFAULT 'en',
  education_level   VARCHAR(100),
  employment_status VARCHAR(50),
  bpl               BOOLEAN NOT NULL DEFAULT FALSE,
  disability        BOOLEAN NOT NULL DEFAULT FALSE,
  pregnant          BOOLEAN NOT NULL DEFAULT FALSE,
  daughter_u10      BOOLEAN NOT NULL DEFAULT FALSE,
  no_pucca_house    BOOLEAN NOT NULL DEFAULT FALSE,
  owns_land         BOOLEAN NOT NULL DEFAULT FALSE,
  notify_enabled    BOOLEAN NOT NULL DEFAULT FALSE,
  profile_complete  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS schemes (
  scheme_id          SERIAL PRIMARY KEY,
  code               VARCHAR(50) UNIQUE NOT NULL,              -- short id used by the frontend, e.g. 'kisan'
  scheme_name        VARCHAR(200) NOT NULL,
  name_hi            VARCHAR(250),
  name_mr            VARCHAR(250),
  category           VARCHAR(100),                             -- edu, agri, health, women, soc, house, biz
  description        TEXT,
  benefits           TEXT,
  benefits_hi        TEXT,
  benefits_mr        TEXT,
  department         VARCHAR(200),
  state              VARCHAR(100) NOT NULL DEFAULT 'All India',
  hide_in_state      VARCHAR(100),                             -- e.g. the central scholarship is hidden in Maharashtra
  application_url    TEXT,
  application_method VARCHAR(100),
  start_date         DATE,
  deadline           DATE,
  renewal_required   BOOLEAN DEFAULT FALSE,
  renewal_period     VARCHAR(100),
  status             VARCHAR(50) NOT NULL DEFAULT 'active'
);

-- One row = one way to qualify. A scheme can have several rows; level 2 = likely eligible, 1 = check at office.
-- NULL in a column means "no restriction". required_flags lists profile flags that must all be true.
CREATE TABLE IF NOT EXISTS eligibility_rules (
  rule_id           SERIAL PRIMARY KEY,
  scheme_id         INT NOT NULL REFERENCES schemes(scheme_id) ON DELETE CASCADE,
  level             SMALLINT NOT NULL CHECK (level IN (1,2)),
  min_age           INT,
  max_age           INT,
  max_income        DECIMAL(12,2),
  occupation        VARCHAR(100),
  state             VARCHAR(100),
  category          VARCHAR(50),
  gender            VARCHAR(20),
  education_level   VARCHAR(100),
  employment_status VARCHAR(50),
  required_flags    TEXT[],
  other_conditions  TEXT
);

CREATE TABLE IF NOT EXISTS documents (                          -- documents a scheme requires
  document_id   SERIAL PRIMARY KEY,
  scheme_id     INT NOT NULL REFERENCES schemes(scheme_id) ON DELETE CASCADE,
  document_name VARCHAR(150) NOT NULL,                         -- document type key: aadhaar, ration, ls, marks ...
  mandatory     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS citizen_documents (                  -- the document vault
  citizen_document_id SERIAL PRIMARY KEY,
  citizen_id    INT NOT NULL REFERENCES citizens(citizen_id) ON DELETE CASCADE,
  document_name VARCHAR(150) NOT NULL,                         -- document type key
  original_name VARCHAR(150),
  mime_type     VARCHAR(50),
  size_bytes    INT,
  document_path TEXT NOT NULL,                                 -- path inside backend/uploads, not the file itself
  status        VARCHAR(50) DEFAULT 'uploaded',
  verified      BOOLEAN NOT NULL DEFAULT FALSE,                -- stays false until a real verification step exists
  uploaded_at   TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS recommendations (
  recommendation_id     SERIAL PRIMARY KEY,
  citizen_id            INT NOT NULL REFERENCES citizens(citizen_id) ON DELETE CASCADE,
  scheme_id             INT NOT NULL REFERENCES schemes(scheme_id) ON DELETE CASCADE,
  match_score           DECIMAL(5,2),
  reason                TEXT,
  recommendation_status VARCHAR(50) NOT NULL DEFAULT 'new',    -- new / dismissed
  created_at            TIMESTAMP NOT NULL DEFAULT now(),
  UNIQUE (citizen_id, scheme_id)
);

CREATE TABLE IF NOT EXISTS alerts (
  alert_id   SERIAL PRIMARY KEY,
  citizen_id INT NOT NULL REFERENCES citizens(citizen_id) ON DELETE CASCADE,
  scheme_id  INT NOT NULL REFERENCES schemes(scheme_id) ON DELETE CASCADE,
  alert_type VARCHAR(50) NOT NULL DEFAULT 'reminder',
  alert_date DATE NOT NULL,
  message    TEXT,
  is_sent    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_rules_scheme ON eligibility_rules(scheme_id);
CREATE INDEX IF NOT EXISTS idx_docs_scheme  ON documents(scheme_id);
CREATE INDEX IF NOT EXISTS idx_cdocs_citizen ON citizen_documents(citizen_id);
CREATE INDEX IF NOT EXISTS idx_alerts_due   ON alerts(alert_date) WHERE is_sent = FALSE;

-- Added with the extended profile page (safe on both new and existing databases)
ALTER TABLE citizens ADD COLUMN IF NOT EXISTS email VARCHAR(150);
ALTER TABLE citizens ADD COLUMN IF NOT EXISTS family_size SMALLINT CHECK (family_size BETWEEN 1 AND 30);

-- Files are stored in the database (BYTEA) so the app also runs on hosts without a persistent disk, such as Vercel
ALTER TABLE citizen_documents ADD COLUMN IF NOT EXISTS file_data BYTEA;
ALTER TABLE citizen_documents ALTER COLUMN document_path DROP NOT NULL;
