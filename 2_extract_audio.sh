#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do

    if [ ! -f ${video_dir}screen.mp4 ]; then
        echo "Skipping $video_dir, no screen.mp4";
        continue
    fi
    if [ ! -f ${video_dir}cam.mp4 ]; then
        echo "Skipping $video_dir, no cam.mp4";
        continue
    fi

    ffmpeg \
        -i "${video_dir}screen.mp4" \
        -vn \
        "${video_dir}screen.wav"

    ffmpeg \
        -i "${video_dir}cam.mp4" \
        -vn \
        "${video_dir}cam.wav"

    # Compress the audio for better comparison in audacity, and to
    # improve overall soundquality
    sox "${video_dir}cam.wav" "${video_dir}cam_normalized.wav" compand 0.3,1 6:-70,-60,-20 -8 -90 0.2
    sox "${video_dir}screen.wav" "${video_dir}screen_normalized.wav" compand 0.3,1 6:-70,-60,-20 -8 -90 0.2
done
