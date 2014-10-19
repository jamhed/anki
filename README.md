About Anki
==========

Anki is a program which makes remembering things easy. Because it's a lot more efficient than traditional study methods, you can either greatly decrease your time spent studying, or greatly increase the amount you learn.

This Anki Tool
==============

Allows to import Google Translate phrasebook to AnkiWeb account. You need to have a Google account with login/password and Anki Web account with login/password.

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

I use Anki REST API to retrieve sqlite database to get word list from it, then I use AnkiWeb API (slow) to add cards to decks because I don't
want to recreate anki database management layer (it is complicated and not well documented).

If only AnkiWeb API have methods to retrieve deck list, words in deck and commit more than one card at once it would be much simplier and easier.

References
==========

https://translate.google.com

https://ankiweb.net

https://ankisrs.net
