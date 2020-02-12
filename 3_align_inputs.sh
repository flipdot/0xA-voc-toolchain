#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do

    if [ ! -f ${video_dir}screen_normalized.wav ]; then
        echo "Skipping $video_dir, no screen_normalized.wav";
        continue
    fi
    if [ ! -f ${video_dir}cam_normalized.wav ]; then
        echo "Skipping $video_dir, no cam_normalized.wav";
        continue
    fi

    # To align the videos, manual work is required. We will open both
    # audio files for the user in audacity. The user has to move one
    # audiotrack and write down the offset that is required to
    # have both in sync.

    # Generate a "lof" file, this allows us to open multiple files in audacity
    echo 'file "cam_normalized.wav"' > ${video_dir}audacity.lof
    echo 'file "screen_normalized.wav"' >> ${video_dir}audacity.lof
    audacity ${video_dir}audacity.lof
    unset screen_offset
    regex="^[0-9]{2}:[0-9]{2}:[0-9]{2}\.?[0-9]*$"
    while [[ ! $screen_offset =~ $regex ]]; do
        read -p 'Enter timestamp to sync both files (hh:mm:ss.s): ' screen_offset
    done
    rm ${video_dir}audacity.lof
    echo $screen_offset > ${video_dir}screen_offset.txt
done
