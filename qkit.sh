#!/bin/env bash

source ./lib.sh

if [ ! -d "/tmp/qkit" ]; then
  mkdir -p /tmp/qkit
fi

run=$(gum choose "subdomains" "revshells")

$run
