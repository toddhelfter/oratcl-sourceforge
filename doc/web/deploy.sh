#!/bin/sh
# Deploy doc/web/ to SourceForge's Project Web service (oratcl.sourceforge.net).
#
# Usage: doc/web/deploy.sh <sourceforge-username>
#
# You will be prompted for your SourceForge password/passphrase interactively
# by sftp. Local filenames here intentionally differ from the stale filenames
# still live on the server (manpage.html, changelog.html,
# OraTcl_Users_Guide_and_Reference.pdf) -- those are removed and replaced with
# our current names (oratcl.html, CHANGELOG.html,
# Oratcl_Users_Guide_and_Reference.pdf).

set -eu

user="${1:?usage: $0 <sourceforge-username>}"
dir="$(cd "$(dirname "$0")" && pwd)"
remote=/home/project-web/oratcl/htdocs

# Deliberately not using "sftp -b -": batch mode forces SSH's BatchMode=yes,
# which disables password/keyboard-interactive auth and only allows key-based
# login. Omitting -b lets sftp read commands from stdin while still prompting
# for your password on the controlling terminal.
sftp "$user@web.sourceforge.net" <<EOF
cd $remote
-rm manpage.html
-rm changelog.html
-rm OraTcl_Users_Guide_and_Reference.pdf
lcd $dir
put index.html
put FAQ.html
put oratcl.html
put CHANGELOG.html
put Oratcl_Users_Guide_and_Reference.pdf
put -r css
put -r images
EOF
