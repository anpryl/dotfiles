#!/usr/bin/env sh

for SINK in `pacmd list-sinks | grep 'index:' | cut -b12-`
do
  pactl set-sink-mute $SINK 0
done
