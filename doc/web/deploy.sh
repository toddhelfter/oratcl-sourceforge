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
#
# The 2026 HTML5/CSS redesign also dropped the old css/1.css stylesheet (and
# its images/backgrounds/ tiled-texture assets, images/logo.jpg placeholder,
# and images/slogo_xhtml10.png validator badge) in favor of css/style.css --
# those are removed from the server too, since "put -r" won't delete files
# that no longer exist locally.
#
# doc/web/Oratcl_Users_Guide_and_Reference.pdf is a symlink to the canonical
# copy at doc/Oratcl_Users_Guide_and_Reference.pdf (avoids two copies
# drifting out of sync); sftp's "put" follows it transparently when reading.

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
-rm css/1.css
-rm images/logo.jpg
-rm images/slogo_xhtml10.png
-rm images/backgrounds/a_hover.jpg
-rm images/backgrounds/back.png
-rm images/backgrounds/desc.jpg
-rm images/backgrounds/hover.jpg
-rm images/backgrounds/li.gif
-rm images/backgrounds/mainbar.jpg
-rm images/backgrounds/menu.jpg
-rm images/backgrounds/submenua.gif
-rm images/backgrounds/submenua.png
-rm images/backgrounds/submenua_hover.jpg
-rmdir images/backgrounds
lcd $dir
put index.html
put FAQ.html
put oratcl.html
put CHANGELOG.html
put Oratcl_Users_Guide_and_Reference.pdf
put -r css
put -r images
EOF
