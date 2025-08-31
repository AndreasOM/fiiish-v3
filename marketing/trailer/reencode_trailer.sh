#!/bin/sh

#ffmpeg -i trailer-scripted.avi -c:v libx264 -preset veryslow -qp 0 -c:a copy trailer-scripted.mp4
ffmpeg -i trailer-scripted.avi -c:v libx264 -preset veryfast -crf 20 -c:a copy trailer-scripted.mp4

