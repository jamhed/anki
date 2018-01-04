#!/bin/sh -e
docker build $BUILD_FLAGS -t jamhed/anki . \
   --build-arg google_login=$GOOGLE_LOGIN \
   --build-arg google_password=$GOOGLE_PASSWORD \
   --build-arg anki_login=$ANKI_LOGIN \
   --build-arg anki_password=$ANKI_PASSWORD
