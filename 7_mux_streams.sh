#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    if [ ! -f ${video_dir}output.mp4 ]; then
        echo "Skipping $video_dir, no output.mp4";
        continue
    fi
    if [ ! -f ${video_dir}only_screen_output.mp4 ]; then
        echo "Skipping $video_dir, no only_screen_output.mp4";
        continue
    fi

    # we combine both, splitscreen and only slides, into a single file
    # with multiple video streams. This allows separate downloading on
    # media.ccc.de
    ffmpeg \
        -i ${video_dir}output.mp4 \
        -i ${video_dir}only_screen_output.mp4 \
        -c copy \
        -map 0:v \
        -map 1:v \
        -map 0:a \
        -disposition:0 default \
        -disposition:1 none \
        ${video_dir}all_streams.mp4
done
