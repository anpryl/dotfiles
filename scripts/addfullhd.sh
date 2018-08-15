#!/usr/bin/env sh

cvt 1920 1080 60
xrandr --addmode eDP-1 1920x1080_60.00
xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
