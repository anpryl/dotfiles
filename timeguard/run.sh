#!/usr/bin/env sh

xhost +si:localuser:root && \
sudo docker run -d -ti --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  timeguard
