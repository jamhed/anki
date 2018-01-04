About Anki
==========

Anki is a program which makes remembering things easy. Because it's a lot more efficient than traditional study methods, you can either greatly decrease your time spent studying, or greatly increase the amount you learn.

About this Repo
===============

These tools allow to use Google Translate service in command-line to translate words, and to retrieve Google Translate phrase books as a JSON list.

Notes
=====

Translate works by generating Google token key (tk), see [Token](lib/Token.pm), and doesn't require to authenticate.
In order to access Google translate phrase book you need to authenticate though.

Note that ankiweb.net bans ip addresses with too many (3 or 4 in an hour) authentication requests, for the reason unknown.

Dependencies
============

Perl and some modules (assume you have cpanm installed):
```sh
cpanm JSON DBI DBD::SQLite LWP::UserAgent LWP::Protocol::https
```

Docker
======

Build docker image (provide credentials):
```sh
GOOGLE_LOGIN=... GOOGLE_PASSWORD=... ANKI_LOGIN=... ANKI_PASSWORD=... ./build.sh
```

Use docker image:
```sh
docker run -it jamhed/anki bin/translate.pl en ru test
docker run -it jamhed/anki bin/google-phrasebook.pl
```

Usage
=====

Create config.json file with proper login/password:

```json
{
   "google": {
      "login": "",
      "password": ""
   },
   "anki": {
      "login": "",
      "password": ""
   }
}
```

Retrieve Google Translate pharse book:

```sh
bin/google-phrasebook.pl > phrasebook.json
```

Copy phrases to AnkiWeb:

```sh
bin/anki-put.pl Basic phrasebook.json
```

Translate a word:
```sh
bin/tranlsate.pl en ru help
```

Translate a word in raw json:
```sh
bin/tranlsate-json.pl en ru help
```

Dump ankiweb as SQLite DB:
```sh
bin/anki-db.pl db_file_name
```

Put a word into AnkiWeb:
```sh
bin/anki-put.pl Basic File.json
```

where File.json is supposed to be a Google translate phrase book [output](eg/phrasebook-output.json).

Retrieve phrase book, translate each word and put it to AnkiWeb:
```sh
bin/anki-sync.pl Basic en-ru
```

References
==========

* https://translate.google.com
* https://ankiweb.net
* https://ankisrs.net
