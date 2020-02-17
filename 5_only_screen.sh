#!/bin/bash

calc_timestamp() {
    python3 -c "from datetime import timedelta;f=lambda t: timedelta(hours=int(t[:2]), minutes=int(t[3:5]), seconds=int(t[6:8]), microseconds=int(''.join([t[9+i:10+i] or '0' for i in range(6)])));print(f('$1')$2f('$3'))"
}


. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    if [ ! -f ${video_dir}screen_offset.txt ]; then
        echo "Skipping $video_dir, no screen_offset.txt";
        continue
    fi
    if [ ! -f ${video_dir}talk_start.txt ]; then
        echo "Skipping $video_dir, no talk_start.txt";
        continue
    fi
    if [ ! -f ${video_dir}talk_end.txt ]; then
        echo "Skipping $video_dir, no talk_end.txt";
        continue
    fi
    # The audio of the screen is slightly delayed.
    # Fix this delay with -itsoffset
    # We assume that every screen recording has about the same delay
    # (see settings.env for the value).
    # Fixme if this is not the case
    screen_offset=$(cat ${video_dir}screen_offset.txt)
    talk_start=$(cat ${video_dir}talk_start.txt)
    talk_end=$(cat ${video_dir}talk_end.txt)
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -ss $(calc_timestamp $talk_start - $screen_offset) \
        -to $(calc_timestamp $talk_end - $screen_offset) \
        -itsoffset -$SCREEN_AUDIO_OFFSET \
        -i ${video_dir}screen.mp4 \
        -ss $(calc_timestamp $talk_start - $screen_offset) \
        -to $(calc_timestamp $talk_end - $screen_offset) \
        -i ${video_dir}screen_normalized.wav \
        -map 0:v \
        -map 1:a \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        ${video_dir}${PREFIX}combined.mp4
done
