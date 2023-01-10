#!usr/bin/env bash

file="$@"

while read -r line; do
    if [[ $line =~ ^## ]]; then
      continue
    else 
      echo -e "$line\n"
    fi
done <$file


