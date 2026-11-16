// Checks titles.js against the titles Gmail and Outlook set: node titles.test.js
// Runs the script as the page would, with a stand-in document and observer.

const fs = require('fs');
const src = fs.readFileSync(require('path').join(__dirname, 'titles.js'), 'utf8');
function run(hostname, search, titles) {
  const out = [];
  const document = { head: {}, _t: '', get title() { return this._t; }, set title(v) { this._t = v; } };
  let observer;
  class MutationObserver { constructor(f) { observer = f; } observe() {} }
  const location = { hostname, search };
  const LABELS = { 'outlook.live.com': 'me@hotmail.example' };
  document._t = titles[0];
  new Function('document', 'location', 'MutationObserver', 'LABELS', src)(document, location, MutationObserver, LABELS);
  out.push(document.title);
  for (const t of titles.slice(1)) { document._t = t; if (observer) { observer(); observer(); } out.push(document.title); }
  return out;
}
const eq = (a, b, name) => { const ok = JSON.stringify(a) === JSON.stringify(b); console.log((ok ? 'ok   ' : 'FAIL ') + name + (ok ? '' : ' got ' + JSON.stringify(a))); if (!ok) process.exitCode = 1; };
eq(run('mail.google.com', '', ['Inbox (3) - me@a.example - Gmail', 'Re: invoice for bob@x.example - me@a.example - Gmail', 'Inbox - me@a.example - Gmail', 'Inbox (1,204) - me@a.example - Gmail']),
   ['me@a.example (3)', 'me@a.example (3)', 'me@a.example', 'me@a.example (1,204)'], 'gmail: count, kept in a message view, cleared, last address wins');
eq(run('mail.google.com', '?fs=1', ['Gmail', 'Compose Mail - me@a.example - Gmail', 'Compose Mail - me@a.example - Gmail']), ['Gmail', 'Compose Mail - me@a.example - Gmail', 'Compose Mail - me@a.example - Gmail'], 'compose window keeps its title whatever the URL');
eq(run('outlook.live.com', '', ['Mail - Some Name - Outlook', 'Mail - Some Name - Outlook']), ['me@hotmail.example', 'me@hotmail.example'], 'outlook: label by host, re-applied');
eq(run('outlook.office.com', '', ['Mail - Some Name - Outlook']), ['Mail - Some Name - Outlook'], 'host without a label is left alone');
