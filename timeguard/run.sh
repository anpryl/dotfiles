#!/usr/bin/env sh

xhost +si:localuser:root && \
sudo docker run -d -ti \
  --name=timeguard \
  -e DISPLAY=$DISPLAY \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  timeguard
