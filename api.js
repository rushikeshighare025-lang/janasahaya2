/* Tiny fetch wrapper for the JanSahay API. Sends the login cookie, JSON in/out, redirects to /login on 401. */
function api(path, o) {
  o = o || {};
  var h = {}, b = o.body;
  if (b && !(b instanceof FormData)) { h['Content-Type'] = 'application/json'; b = JSON.stringify(b); }
  return fetch('/api' + path, { method: o.method || 'GET', headers: h, body: b, credentials: 'same-origin' }).then(function (r) {
    if (r.status === 401 && path.indexOf('/auth/') !== 0) { location.href = '/login'; return new Promise(function () {}); }
    return r.json().catch(function () { return {}; }).then(function (j) {
      if (!r.ok) { var e = new Error(j.error || 'Request failed'); e.code = j.code; throw e; }
      return j;
    });
  });
}
