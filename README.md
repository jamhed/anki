Anki-Tools
==========

Anki flashcard tools. Allows to import Google Translate phrasebook with AnkiWeb account. You need to have a Google account with login/password and Anki Web account with login/password.

Usage
=====

./google-get google-login google-password > words

Downloads and stores google phrasebook into words file (which is simple json array of arrays).

./anki-put anki-login anki-password words

Reads words file and uploads it to AnkiWeb.

Notes
=====

Currently this script doesn't check that word definition is already exists, so it may and will cause word duplicates. I've started implementing Anki sync protocol in proto.pl file, but this is not done yet.
