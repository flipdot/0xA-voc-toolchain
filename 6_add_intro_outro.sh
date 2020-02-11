#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    if [ ! -f ${video_dir}combined.mp4 ]; then
        echo "Skipping $video_dir, no combined.mp4";
        continue
    fi
    if [ ! -f ${video_dir}intro.mp4 ]; then
        echo "Skipping $video_dir, no intro.mp4";
        continue
    fi
    transition_duration=500

    if [ -f ${video_dir}transitioned.mp4 ]; then
        read -p "File '${video_dir}transitioned.mp4' already exists. Overwrite ? [y/N] " overwrite
    fi

    if [ ! -f ${video_dir}transitioned.mp4 ] || [[ $overwrite =~ [yY] ]]; then
        ffmpeg-concat \
            -d ${transition_duration}
            -o ${video_dir}transitioned.mp4 \
            ${video_dir}intro.mp4 \
            ${video_dir}combined.mp4 \
            $WORKING_DIR/outro.mp4
    fi

    intro_length=$(ffprobe \
        -v error \
        -show_entries stream=duration \
        -of default=noprint_wrappers=1:nokey=1 \
        ${video_dir}intro.mp4)

    offset=$(echo "$intro_length - ($transition_duration / 1000)" | bc -l)

    # ffmpeg-concat removes the audio, so copy it back:
    ffmpeg \
        -y \
        -i ${video_dir}transitioned.mp4 \
        -vn -itsoffset $offset -i ${video_dir}combined.mp4 \
        -c:v copy \
        -c:a copy \
        ${video_dir}output.mp4
done
