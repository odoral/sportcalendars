#!/usr/bin/env bash

set -eo

export TZ=Europe/Madrid
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Build"
./gradlew clean build

echo "Run"
java -jar ./sportcalendars-web-scraper/build/libs/sportcalendars-web-scraper-all.jar -pd=./ -gr

if ! git diff --unified=0 | grep -e "^[+-][^-+]" | grep -ve "^.DTSTAMP\|^.UID"; then
  echo "No changes in existing events."
else
  echo "New events detected!"
  echo "Configure git"
  git config --global user.name 'github-actions[bot]'
  git config --global user.email 'github-actions[bot]@users.noreply.github.com'

  echo "Commit"
  git commit -a -m "[AUTOMATION] ${TIMESTAMP} execution"
  git push origin master
  git tag "${TIMESTAMP}"
  git push origin --tags
fi

echo "Done!"