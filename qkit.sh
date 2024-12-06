#!/bin/env bash

# -----------------------------------------------------------------
#
#                             SUBDOMAINS
#
# -----------------------------------------------------------------

subdomains(){
  DATE=$(date)

  TARGET=$(gum input --value "$TARGET" --placeholder "*.target.domain")

  gum spin --spinner dot --title "amass goes brrrr" --  amass enum -passive -d "$TARGET" | tee "/tmp/qkit/${DATE}_amass.txt"

  grep -oE '([a-zA-Z0-9]+\.)*[a-zA-Z0-9]+\.[a-zA-Z]{2,}' "/tmp/qkit/${DATE}_amass.txt" > "/tmp/qkit/${DATE}_domains.txt"

  cat "/tmp/qkit/${DATE}_" | httprobe > realurls.txt
}

# -----------------------------------------------------------------
#
#                             REVSHELLS
#
# -----------------------------------------------------------------

revshells(){
  revshell=$(gum choose "sh" "py3" "pwsh" "php")

  $revshell
}

sh(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  RSHELL=`cat ./revshells/sh.txt | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g`
  
  gum pager "$RSHELL"
}

# TO FIX
py3(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  RSHELL=`cat ./revshells/py3.txt | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g`
  
  gum pager "$RSHELL"
}

pwsh(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  RSHELL=`cat ./revshells/pwsh.txt | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g`
  
  gum pager "$RSHELL"
}

php(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  RSHELL=`cat ./revshells/php.txt | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g`
  
  gum pager "$RSHELL"
}

if [ ! -d "/tmp/qkit" ]; then
  mkdir -p /tmp/qkit
fi

run=$(gum choose "subdomains" "revshells")

$run
