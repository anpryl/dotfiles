#!/usr/bin/env sh

for SOURCE in `pacmd list-sources | grep 'index:' | cut -b12-`
do
  pactl set-source-mute $SOURCE toggle
done
