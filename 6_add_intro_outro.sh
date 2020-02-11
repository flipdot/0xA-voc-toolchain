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

    offset=$(echo "$intro_length * 1000 - $transition_duration" | bc)

    # ffmpeg-concat removes the audio, so copy it back:
    ffmpeg \
        -y \
        -i ${video_dir}transitioned.mp4 \
        -vn -i ${video_dir}combined.mp4 \
        -i ${WORKING_DIR}/intro.wav \
        -filter_complex \
        "
        [1:a]
            adelay=$offset|$offset
        [delayed];
        [2:a] [delayed] amix [mixed_audio]
        "\
        -c:v copy \
        -map 0:v \
        -map '[mixed_audio]' \
        ${video_dir}output.mp4
done
