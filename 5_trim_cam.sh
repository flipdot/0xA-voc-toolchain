#!/bin/bash

. settings.env

for video_dir in $WORKING_DIR/*/ ;
do
    if [ ! -f $video_dir/screen_offset.txt ]; then
        echo "Skipping $video_dir";
        continue
    fi
    ffmpeg \
        -hwaccel vaapi \
        -vaapi_device /dev/dri/renderD128 \
        -ss $(cat $video_dir/screen_offset.txt) \
        -i "$video_dir/cam.mp4" \
        -to 00:01:00.000 \
        -vf 'format=nv12,hwupload' \
        -c:v h264_vaapi \
        -qp:v $QUALITY \
        "$video_dir/cam_aligned_with_screen.mp4"
done

echo "*********************"
echo "*********************"
echo "Now, you have one minute startings of every cam recording. Open them, and write down the offset to directory/talk_start_offset.txt when the talk actually begins!"
echo "Format must be compatible with ffmpeg, e.g. 00:00:03.200 for 3.2 seconds"
