// The window group bar shows each window's title, and Hyprland cannot override
// one, so the title is rewritten in the page: "address (unread)".
//
// The sites keep setting their own title, so every change of theirs is answered
// with ours. `mine` is what we wrote last, which tells our own write apart from
// theirs and keeps the observer from answering itself.

const ADDRESS = /[^\s<>()]+@[^\s<>()]+\.[^\s<>()]+/g;
const GMAIL = location.hostname === "mail.google.com";

// A compose window opened from a mailto: link keeps its own title. Told by the
// title: Gmail redirects the link, so the URL no longer says it is one.
const COMPOSE = /^Compose Mail - /;

let mine = null;
let unread = "";

function retitle() {
  const theirs = document.title;
  if (theirs === mine || COMPOSE.test(theirs)) return;

  let address = LABELS[location.hostname];

  if (GMAIL) {
    // "Inbox (3) - address - Gmail". Only the inbox view carries the count, so
    // it is remembered across the views that do not ("Subject - address - Gmail").
    // The account is the last address: a subject can name one too.
    const found = theirs.match(ADDRESS);
    if (!found) return;
    address = found[found.length - 1];

    const inbox = theirs.match(/^Inbox(?: \(([\d.,]+)\))? - /);
    if (inbox) unread = inbox[1] || "";
  }

  if (!address) return;

  mine = unread ? `${address} (${unread})` : address;
  document.title = mine;
}

new MutationObserver(retitle).observe(document.head, { childList: true, subtree: true, characterData: true });
retitle();
