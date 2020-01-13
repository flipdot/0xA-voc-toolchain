#!/bin/bash

# Do not use a trailing slash
WORKING_DIR=$HOME/private/hackumenta_videos

# For valid quality values, search for the "qp" parameter here:
# https://trac.ffmpeg.org/wiki/Hardware/VAAPI
QUALITY=19

# for video_dir in $WORKING_DIR/*/ ;
# do
# TODO: Wrong input files, we need to cut them first
video_dir=$WORKING_DIR/"01_Opening"
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -i $video_dir/intro.mp4 \
        -i $WORKING_DIR/background.mp4 \
        -i $video_dir/screen_normalized.mkv \
        -i $video_dir/cam.mp4 \
        -i $WORKING_DIR/outro.mp4 \
        -filter_complex \
        "
        [2:v]
            scale=1536:864
        [slides];
        [3:v]
            scale=480:270
        [cam];
        [4:v]
            fade=
                t=in:
                alpha=1,
            setpts=PTS-STARTPTS+20/TB
        [outro];
        [1:v][cam]
            overlay=
               x=main_w-overlay_w:
               y=main_h-overlay_h
        [bg_with_cam];
        [bg_with_cam][slides]
            overlay
        [talk];
        [0:v][talk]
            overlay
        [intro_with_talk];
        [intro_with_talk][outro]
            overlay
        [v]
        " \
        -map "[v]" \
        -map 2:a \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        $video_dir/result.mp4
# done
