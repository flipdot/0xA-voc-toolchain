#!/bin/bash

# Do not use a trailing slash
WORKING_DIR=$HOME/private/hackumenta_videos

for video_dir in $WORKING_DIR/*/ ;
do
    # Create an audio file from screen recording and cam recording.
    # This allows using a third party program like audacity to synchronize
    # both files
    # Open the files and search for common waveforms, and look for the offset
    # that is required to synchronize them

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
