Anki-Tools
==========

Anki flashcard tools. Allows to import Google Translate phrasebook to AnkiWeb account. You need to have a Google account with login/password and Anki Web account with login/password.

Usage
=====

./google-get.pl google-login google-password > words

Retrieves and reformats as JSON list of lists Google phrasebook.

./anki-put.pl anki-login anki-password words

Reads words file as dumped from google-get.pl and uploads it to AnkiWeb. May and will cause doubles if run with same words more than once.

./anki-db.pl anki-login anki-password anki-db

Dumps AnkiWeb database in SQLite3 format. You can use standard sqlite3 tool to access it manually.

./anki-sync.pl anki-login anki-password google-login google-password

Syncs Google Translate phrasebook with AnkiWeb account.

Notes
=====

I use Anki REST API to retrieve sqlite database to get word list from it, then I use AnkiWeb API to add cards to decks because I don't
want to recreate anki database management layer (it is a bit complicated and not well documented), and the later is a bit slow.

If only AnkiWeb API have methods to retrieve deck list, words in deck and commit more than one card at once it would be much simplier and easier.

References
==========

http://translate.google.com

http://ankiweb.net
