#!/bin/bash

. settings.env

for input_video_dir in $INPUT_DIR/*/ ;
do
    # For each input directory, create an output directory
    mkdir -p $WORKING_DIR/${input_video_dir}

    # Take all "cam_01.mp4", "cam_02.mp4" video files and concat them, so we
    # get a single cam.mp4 output.
    # Also, use a more efficient encoding to reduce filesize to about 1/2 to 1/4
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -f concat \
        -safe 0 \
        -i <(for f in ${input_video_dir}cam*; do echo "file '$PWD/$f'"; done) \
        -c copy \
        -vf 'format=nv12,hwupload' \
        -c:v h264_vaapi \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        "$WORKING_DIR/${input_video_dir}cam.mp4"

    # The screen capture was in raw format. Reencode it to get a sane file size
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -i "./${input_video_dir}screen_raw.avi" \
        -vf 'format=nv12,hwupload' \
        -c:v h264_vaapi \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        "$WORKING_DIR/${input_video_dir}screen.mp4"
done

cd $WORKING_DIR/..
tar -cf $WORKING_DIR.tar $WORKING_DIR
