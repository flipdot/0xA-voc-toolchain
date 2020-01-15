#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do

    if [ ! -f $video_dir/screen_offset.txt ]; then
        echo "Skipping $video_dir";
        continue
    fi
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -i $WORKING_DIR/background.mp4 \
        -i $video_dir/screen_normalized.mkv \
        -ss $(cat $video_dir/screen_offset.txt) \
        -i $video_dir/cam.mp4 \
        -filter_complex \
        "
        [1:v]
            scale=1536:864
        [slides];
        [2:v]
            scale=480:270
        [cam];
        [0:v][cam]
            overlay=
               x=main_w-overlay_w:
               y=main_h-overlay_h:
               shortest=1
        [bg_with_cam];
        [bg_with_cam][slides]
            overlay
        [talk]
        " \
        -map "[talk]" \
        -map 1:a \
        -ss $(cat $video_dir/talk_start_offset.txt) \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        $video_dir/combined.mp4
done
