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

    # The audio of the screen is slightly delayed.
    # Fix this delay with -itsoffset
    # We assume that every screen recording has about the same delay (700ms).
    # Fixme if this is not the case
    ffmpeg \
        -itsoffset 0.7 \
        -i "${video_dir}screen.mp4" \
        -vn \
        "${video_dir}screen.wav"

    ffmpeg \
        -i "${video_dir}cam.mp4" \
        -vn \
        "${video_dir}cam.wav"

    sox --norm "${video_dir}screen.wav" "${video_dir}screen_normalized.wav"
    sox --norm "${video_dir}cam.wav" "${video_dir}cam_normalized.wav"
done
