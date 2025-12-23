#!/bin/bash
# Tangle Emacs.org to generate config files

ORG_FILE="${DOOMDIR}/Emacs.org"

emacs --batch \
      --eval "(require 'org)" \
      --eval "(org-babel-tangle-file \"${ORG_FILE}\")"

echo "Tangled: ${ORG_FILE}"
