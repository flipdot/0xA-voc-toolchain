#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    # Create an audio file from screen recording and cam recording.
    # This allows using a third party program like audacity to synchronize
    # both files
    # Open the files and search for common waveforms, and look for the offset
    # that is required to synchronize them. Write the offset into a textfile:
    # Example:
    # echo "00:02:15.120" > screen_offset.txt

    ffmpeg \
        -y \
        -i "${video_dir}screen_normalized.mkv" \
        -vn \
        -acodec copy \
        "${video_dir}audio_screen.wav"

    ffmpeg \
        -y \
        -i "${video_dir}cam_normalized.mkv" \
        -vn \
        -acodec copy \
        "${video_dir}audio_cam.wav"
done
