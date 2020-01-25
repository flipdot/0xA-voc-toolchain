#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    # Normalize the audio of every screen file, so the volume is about
    # the same everywhere.
    # We also normalize the cam audio, so it will be simpler to compare
    # the audio tracks in a visual tool (e.g. audacity)

    # TODO: This produces quite large files, maybe fix me
    ffmpeg-normalize \
        -pr \
        -t -17 \
        -lrt 14.0 \
        -tp -1 \
        -f "$video_dir/screen_audio_delay_fixed.mp4" \
        -o "$video_dir/screen_normalized.mkv"

    ffmpeg-normalize \
        -pr \
        -t -17 \
        -lrt 14.0 \
        -tp -1 \
        -f "$video_dir/cam.mp4" \
        -o "$video_dir/cam_normalized.mkv"

done
