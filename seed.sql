-- Scheme data for JanSahay. Safe to re-run: schemes are upserted by code; rules and required documents are rebuilt.
-- Eligibility rules are simplified from published criteria and can be out of date. Verify before relying on them.
BEGIN;
DELETE FROM eligibility_rules;
DELETE FROM documents;

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('kisan', 'PM-KISAN', 'पीएम-किसान', 'पीएम-किसान', 'agri', '₹6,000 a year in 3 instalments', '₹6,000 a year in 3 instalments', '₹6,000 प्रति वर्ष, 3 किस्तों में', 'वार्षिक ₹६,००० तीन हप्त्यांत', 'Ministry of Agriculture & Farmers Welfare', 'All India', NULL, 'https://pmkisan.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='kisan';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'land',TRUE FROM schemes WHERE code='kisan';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='kisan';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['owns_land']::text[] FROM schemes WHERE code='kisan';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'farmer',NULL,NULL,NULL FROM schemes WHERE code='kisan';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('jay', 'Ayushman Bharat (PM-JAY)', 'आयुष्मान भारत (PM-JAY)', 'आयुष्मान भारत (PM-JAY)', 'health', 'Health cover up to ₹5 lakh per family a year', 'Health cover up to ₹5 lakh per family a year', 'प्रति परिवार ₹5 लाख तक स्वास्थ्य बीमा', 'प्रति कुटुंब ₹५ लाखांपर्यंत आरोग्य विमा', 'National Health Authority', 'All India', NULL, 'https://mera.pmjay.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='jay';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ration',TRUE FROM schemes WHERE code='jay';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['bpl']::text[] FROM schemes WHERE code='jay';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,250000,NULL,NULL,NULL,NULL FROM schemes WHERE code='jay';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('uj', 'PM Ujjwala Yojana', 'पीएम उज्ज्वला योजना', 'पीएम उज्ज्वला योजना', 'women', 'Free LPG connection', 'Free LPG connection', 'मुफ़्त एलपीजी कनेक्शन', 'मोफत एलपीजी जोडणी', 'Ministry of Petroleum & Natural Gas', 'All India', NULL, 'https://www.pmuy.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='uj';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ration',TRUE FROM schemes WHERE code='uj';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='uj';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,'f',ARRAY['bpl']::text[] FROM schemes WHERE code='uj';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,250000,NULL,NULL,'f',NULL FROM schemes WHERE code='uj';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('apy', 'Atal Pension Yojana', 'अटल पेंशन योजना', 'अटल पेन्शन योजना', 'soc', '₹1,000–5,000 monthly pension after 60', '₹1,000–5,000 monthly pension after 60', '60 के बाद ₹1,000–5,000 मासिक पेंशन', '६० नंतर दरमहा ₹१,०००–५,००० पेन्शन', 'PFRDA, Ministry of Finance', 'All India', NULL, 'https://www.jansuraksha.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='apy';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='apy';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,18,40,NULL,NULL,NULL,NULL,NULL FROM schemes WHERE code='apy';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mat', 'PM Matru Vandana Yojana', 'पीएम मातृ वंदना योजना', 'पीएम मातृ वंदना योजना', 'women', '₹5,000 for the first living child', '₹5,000 for the first living child', 'पहले जीवित बच्चे के लिए ₹5,000', 'पहिल्या अपत्यासाठी ₹५,०००', 'Ministry of Women & Child Development', 'All India', NULL, 'https://pmmvy.wcd.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mat';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mat';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,'f',ARRAY['pregnant']::text[] FROM schemes WHERE code='mat';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('nsp', 'Post-Matric Scholarship (NSP)', 'पोस्ट-मैट्रिक छात्रवृत्ति (NSP)', 'पोस्ट-मॅट्रिक शिष्यवृत्ती (NSP)', 'edu', 'Fee and maintenance support for SC/ST/OBC students', 'Fee and maintenance support for SC/ST/OBC students', 'SC/ST/OBC विद्यार्थियों को फ़ीस और भत्ता', 'SC/ST/OBC विद्यार्थ्यांना शुल्क व भत्ता', 'Ministry of Education (National Scholarship Portal)', 'All India', 'Maharashtra', 'https://scholarships.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='nsp';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,'student','SC',NULL,NULL FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','SC',NULL,NULL FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,'student','ST',NULL,NULL FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','ST',NULL,NULL FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,'student','OBC',NULL,NULL FROM schemes WHERE code='nsp';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','OBC',NULL,NULL FROM schemes WHERE code='nsp';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('ssy', 'Sukanya Samriddhi Yojana', 'सुकन्या समृद्धि योजना', 'सुकन्या समृद्धी योजना', 'women', 'High-interest savings for a girl child', 'High-interest savings for a girl child', 'बेटी के लिए ऊँचे ब्याज की बचत', 'मुलीसाठी जास्त व्याजाची बचत', 'Department of Posts / Ministry of Finance', 'All India', NULL, 'https://www.indiapost.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='ssy';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'birth',TRUE FROM schemes WHERE code='ssy';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['daughter_u10']::text[] FROM schemes WHERE code='ssy';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('nsap', 'Old Age Pension (NSAP)', 'वृद्धावस्था पेंशन (NSAP)', 'वृद्धापकाळ पेन्शन (NSAP)', 'soc', 'Monthly pension for senior citizens', 'Monthly pension for senior citizens', 'वरिष्ठ नागरिकों को मासिक पेंशन', 'ज्येष्ठ नागरिकांना मासिक पेन्शन', 'Ministry of Rural Development', 'All India', NULL, 'https://nsap.nic.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='nsap';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ration',TRUE FROM schemes WHERE code='nsap';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='nsap';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='nsap';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,60,NULL,NULL,NULL,NULL,NULL,ARRAY['bpl']::text[] FROM schemes WHERE code='nsap';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,60,NULL,250000,NULL,NULL,NULL,NULL FROM schemes WHERE code='nsap';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('pmay', 'PM Awas Yojana', 'पीएम आवास योजना', 'पीएम आवास योजना', 'house', 'Help to build or buy a pucca home', 'Help to build or buy a pucca home', 'पक्का घर बनाने/खरीदने में मदद', 'पक्के घर बांधण्यास/घेण्यास मदत', 'Ministry of Housing & Urban Affairs / Rural Development', 'All India', NULL, 'https://pmaymis.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='pmay';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='pmay';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='pmay';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,NULL,NULL,NULL,ARRAY['no_pucca_house']::text[] FROM schemes WHERE code='pmay';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['no_pucca_house']::text[] FROM schemes WHERE code='pmay';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('udid', 'Disability pension & UDID card', 'दिव्यांग पेंशन और UDID कार्ड', 'दिव्यांग पेन्शन व UDID कार्ड', 'soc', 'Monthly pension and concessions', 'Monthly pension and concessions', 'मासिक पेंशन और रियायतें', 'मासिक पेन्शन व सवलती', 'Department of Empowerment of Persons with Disabilities', 'All India', NULL, 'https://www.swavlambancard.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='udid';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'udid',TRUE FROM schemes WHERE code='udid';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='udid';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['disability']::text[] FROM schemes WHERE code='udid';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('sv', 'PM SVANidhi', 'पीएम स्वनिधि', 'पीएम स्वनिधी', 'biz', 'Loan from ₹10,000, no collateral', 'Loan from ₹10,000, no collateral', '₹10,000 से बिना गारंटी ऋण', '₹१०,००० पासून विनातारण कर्ज', 'Ministry of Housing & Urban Affairs', 'All India', NULL, 'https://pmsvanidhi.mohua.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='sv';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='sv';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,'vendor',NULL,NULL,NULL FROM schemes WHERE code='sv';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('ladki', 'Mukhyamantri Majhi Ladki Bahin', 'मुख्यमंत्री माझी लाडकी बहीण', 'मुख्यमंत्री माझी लाडकी बहीण', 'women', 'Monthly cash support for women (Maharashtra)', 'Monthly cash support for women (Maharashtra)', 'महिलाओं को मासिक आर्थिक सहायता (महाराष्ट्र)', 'महिलांना मासिक आर्थिक सहाय्य (महाराष्ट्र)', 'Women & Child Development Department, Maharashtra', 'Maharashtra', NULL, 'https://ladakibahin.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='ladki';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='ladki';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='ladki';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='ladki';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,21,65,250000,NULL,NULL,'f',NULL FROM schemes WHERE code='ladki';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('msc', 'Post-Matric Scholarship – SC (MahaDBT)', 'पोस्ट-मैट्रिक छात्रवृत्ति – SC (MahaDBT)', 'पोस्ट-मॅट्रिक शिष्यवृत्ती – SC (MahaDBT)', 'edu', 'Tuition fee and maintenance allowance', 'Tuition fee and maintenance allowance', 'ट्यूशन फ़ीस और रखरखाव भत्ता', 'शिक्षण शुल्क व निर्वाह भत्ता', 'Social Justice Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='msc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='msc';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,'student','SC',NULL,NULL FROM schemes WHERE code='msc';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','SC',NULL,NULL FROM schemes WHERE code='msc';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mobc', 'Scholarship – OBC / VJNT / SBC (MahaDBT)', 'छात्रवृत्ति – OBC / VJNT / SBC (MahaDBT)', 'शिष्यवृत्ती – OBC / VJNT / SBC (MahaDBT)', 'edu', 'Fee reimbursement and allowance', 'Fee reimbursement and allowance', 'फ़ीस प्रतिपूर्ति और भत्ता', 'शुल्क प्रतिपूर्ती व भत्ता', 'Other Backward Bahujan Welfare Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='mobc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mobc';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,100000,'student','OBC',NULL,NULL FROM schemes WHERE code='mobc';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','OBC',NULL,NULL FROM schemes WHERE code='mobc';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mebc', 'Rajarshi Shahu Maharaj Fee Concession (EBC)', 'राजर्षि शाहू महाराज शुल्क सवलत (EBC)', 'राजर्षी शाहू महाराज शिक्षण शुल्क सवलत (EBC)', 'edu', 'Tuition fee concession for open-category students', 'Tuition fee concession for open-category students', 'खुले वर्ग के विद्यार्थियों को फ़ीस में छूट', 'खुल्या प्रवर्गातील विद्यार्थ्यांना शुल्क सवलत', 'Higher & Technical Education Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='mebc';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mebc';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,800000,'student','General',NULL,NULL FROM schemes WHERE code='mebc';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mst', 'Tribal Post-Matric Scholarship (MahaDBT)', 'आदिवासी पोस्ट-मैट्रिक छात्रवृत्ति (MahaDBT)', 'आदिवासी पोस्ट-मॅट्रिक शिष्यवृत्ती (MahaDBT)', 'edu', 'Fee and maintenance support for ST students', 'Fee and maintenance support for ST students', 'ST विद्यार्थियों को फ़ीस और भत्ता', 'ST विद्यार्थ्यांना शुल्क व भत्ता', 'Tribal Development Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='mst';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mst';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,250000,'student','ST',NULL,NULL FROM schemes WHERE code='mst';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'student','ST',NULL,NULL FROM schemes WHERE code='mst';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mpd', 'Dr. Panjabrao Deshmukh Hostel Allowance', 'डॉ. पंजाबराव देशमुख वसतिगृह भत्ता', 'डॉ. पंजाबराव देशमुख वसतिगृह निर्वाह भत्ता', 'edu', 'Hostel and living allowance for students away from home', 'Hostel and living allowance for students away from home', 'बाहर रहने वाले विद्यार्थियों को निवास भत्ता', 'बाहेर राहणाऱ्या विद्यार्थ्यांना निवास भत्ता', 'Higher & Technical Education Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mpd';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'income',TRUE FROM schemes WHERE code='mpd';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'marks',TRUE FROM schemes WHERE code='mpd';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'ls',TRUE FROM schemes WHERE code='mpd';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'domicile',TRUE FROM schemes WHERE code='mpd';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mpd';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,800000,'student',NULL,NULL,NULL FROM schemes WHERE code='mpd';

INSERT INTO schemes (code,scheme_name,name_hi,name_mr,category,description,benefits,benefits_hi,benefits_mr,department,state,hide_in_state,application_url,application_method,status)
VALUES ('mmech', 'Farm Mechanisation Subsidy (MahaDBT)', 'कृषि यांत्रिकीकरण अनुदान (MahaDBT)', 'कृषी यांत्रिकीकरण अनुदान (MahaDBT)', 'agri', 'Subsidy on tractors and farm equipment', 'Subsidy on tractors and farm equipment', 'ट्रैक्टर और कृषि उपकरणों पर अनुदान', 'ट्रॅक्टर व कृषी अवजारांवर अनुदान', 'Agriculture Department, Maharashtra', 'Maharashtra', NULL, 'https://mahadbt.maharashtra.gov.in', 'online', 'active')
ON CONFLICT (code) DO UPDATE SET scheme_name=EXCLUDED.scheme_name,name_hi=EXCLUDED.name_hi,name_mr=EXCLUDED.name_mr,category=EXCLUDED.category,description=EXCLUDED.description,benefits=EXCLUDED.benefits,benefits_hi=EXCLUDED.benefits_hi,benefits_mr=EXCLUDED.benefits_mr,department=EXCLUDED.department,state=EXCLUDED.state,hide_in_state=EXCLUDED.hide_in_state,application_url=EXCLUDED.application_url,application_method=EXCLUDED.application_method,status=EXCLUDED.status;
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'aadhaar',TRUE FROM schemes WHERE code='mmech';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'land',TRUE FROM schemes WHERE code='mmech';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'bank',TRUE FROM schemes WHERE code='mmech';
INSERT INTO documents (scheme_id,document_name,mandatory) SELECT scheme_id,'caste',TRUE FROM schemes WHERE code='mmech';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,2,NULL,NULL,NULL,NULL,NULL,NULL,ARRAY['owns_land']::text[] FROM schemes WHERE code='mmech';
INSERT INTO eligibility_rules (scheme_id,level,min_age,max_age,max_income,occupation,category,gender,required_flags) SELECT scheme_id,1,NULL,NULL,NULL,'farmer',NULL,NULL,NULL FROM schemes WHERE code='mmech';

COMMIT;
