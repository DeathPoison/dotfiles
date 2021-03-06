#!/bin/bash

## screeny
scrot /tmp/screen.png

## pixelate
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
[[ -f $1 ]] && convert /tmp/screen.png $1 -gravity center -composite -matte /tmp/screen.png

## stop music?
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop

## lock screen
i3lock -u -i /tmp/screen.png

## clear image
rm /tmp/screen.png
