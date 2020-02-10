#!/bin/bash

. settings.env

for input_video_dir in $INPUT_DIR/*/ ;
do
    out_dirname=`basename $input_video_dir`
    # For each input directory, create an output directory
    mkdir -p $WORKING_DIR/${out_dirname}

    # Take all "cam_01.mp4", "cam_02.mp4" video files and concat them, so we
    # get a single cam.mp4 output.
    # Also, use a more efficient encoding to reduce filesize to about 1/2 to 1/4
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -f concat \
        -safe 0 \
        -i <(for f in ${input_video_dir}cam*; do echo "file '$f'"; done) \
        -c copy \
        -vf 'format=nv12,hwupload' \
        -c:v h264_vaapi \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        "$WORKING_DIR/${out_dirname}/cam.mp4"

    # The screen capture was in raw format. Reencode it to get a sane file size
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -i "${input_video_dir}screen_raw.avi" \
        -vf 'format=nv12,hwupload' \
        -c:v h264_vaapi \
        -qp:v $QUALITY \
        -c:a aac \
        -b:a 128k \
        "$WORKING_DIR/${out_dirname}/screen.mp4"

    # The intros will simply be copied
    cp "${input_video_dir}intro.mp4" "$WORKING_DIR/${out_dirname}/intro.mp4"
done

cp $INPUT_DIR/background.mp4 $WORKING_DIR/background.mp4
cp $INPUT_DIR/outro.mp4 $WORKING_DIR/outro.mp4

# cd $WORKING_DIR/..
# tar -cf $WORKING_DIR.tar $WORKING_DIR
