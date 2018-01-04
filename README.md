About Anki
==========

Anki is a program which makes remembering things easy. Because it's a lot more efficient than traditional study methods, you can either greatly decrease your time spent studying, or greatly increase the amount you learn.

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

References
==========

https://translate.google.com

https://ankiweb.net

https://ankisrs.net
