#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    # The audio of the screen is slightly delayed. Fix this delay.
    # We assume that every screen recording has about the same delay.
    # Fixme if this is not the case
    ffmpeg \
        -i "${video_dir}screen.mp4" \
        -itsoffset 0.7 \
        -i "${video_dir}screen.mp4" \
        -map 0:v \
        -map 1:a \
        -c copy \
        "${video_dir}screen_audio_delay_fixed.mp4"
done
