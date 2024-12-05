#!/bin/env bash

test(){
  echo "test"
}

subtakeover(){
  DATE=$(date)

  TARGET=$(gum input --value "$TARGET" --placeholder "*.target.domain")

  amass enum -passive -d "$TARGET" | tee "/tmp/qkit/${DATE}_amass.txt"

  #grep -oE '([a-zA-Z0-9]+\.)*[a-zA-Z0-9]+\.[a-zA-Z]{2,}' amass.txt > domains.txt

  #cat domains.txt | httprobe | tee realurls.txt
}
