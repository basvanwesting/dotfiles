// Addresses for mailboxes whose page title does not carry one (Outlook), by host:
//
//   "outlook.live.com": "someone@example.com",
//
// Gmail needs no entry: its title names the address.
//
// Machine-local on purpose: this is the only file of the mail setup that holds
// addresses, and the dotfiles are public. chezmoi only creates it, empty, and
// apply never overwrites it. Do not `chezmoi add` it.
const LABELS = {};
