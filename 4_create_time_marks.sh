#!/bin/bash

diff_timestamps() {
    python3 -c "from datetime import timedelta;f=lambda t: timedelta(hours=int(t[:2]), minutes=int(t[3:5]), seconds=int(t[6:8]), microseconds=int(t[9:] or '0'));d=f('$2')-f('$1');print(d)"
}


sub_seconds_from_timestamp() {
    python3 -c "from datetime import timedelta;f=lambda t: timedelta(hours=int(t[:2]), minutes=int(t[3:5]), seconds=int(t[6:8]), microseconds=int(t[9:] or '0'));d=f('$1')-timedelta(seconds=$2);print(d)"
}

# a=00:03:04.200
# b=00:05:30
# c=$(diff_timestamps $a $b)

. settings.env

regex="^[0-9]{2}:[0-9]{2}:[0-9]{2}\.?[0-9]*$"

for video_dir in $WORKING_DIR/*/ ;
do


    # We need to find the start and the end of the talk. Start mpv with
    # some osd settings set, so the user will be able to search for start
    # and end.

    echo "\"$(basename $video_dir)\" will now start. Search for the start of the talk!"
    read -p 'Press enter '

    if [ -f ${video_dir}screen_offset.txt ]; then
        mpv --osd-fractions --osd-level 2 --start=$(cat ${video_dir}screen_offset.txt) ${video_dir}cam.mp4
    else
        mpv --osd-fractions --osd-level 2 ${video_dir}cam.mp4
    fi

    unset confirmation
    while [[ ! $confirmation =~ [yY] ]]; do
        unset timestamp
        while [[ ! $timestamp =~ $regex ]]; do
            read -p 'When does the talk start? (hh:mm:ss.s): ' timestamp
        done

        replay='y'
        while [[ $replay =~ [yY] ]]; do
            echo "We will now start the video at your time mark, check if it looks good"
            read -p 'Press enter '
            mpv --osd-fractions --osd-level 2 --start=$timestamp --length=3 ${video_dir}cam.mp4
            read -p "Replay? [y/N] " replay
        done;

        read -p 'Does it look good? Confirm with y ' confirmation
    done;
    echo $timestamp > ${video_dir}talk_start.txt


    echo "\"$(basename $video_dir)\" will now start. Search for the end of the talk!"
    read -p 'Press enter '
    mpv --osd-fractions --osd-level 2 --start=-60 ${video_dir}cam.mp4

    unset confirmation
    while [[ ! $confirmation =~ [yY] ]]; do
        unset timestamp
        while [[ ! $timestamp =~ $regex ]]; do
            read -p 'When does the talk end? (hh:mm:ss.s): ' timestamp
        done

        replay='y'
        while [[ $replay =~ [yY] ]]; do
            echo "We will now end the video at your time mark, check if it looks good"
            read -p 'Press enter '
            mpv --osd-fractions --osd-level 2 --start=$(sub_seconds_from_timestamp $timestamp 5) --end=$timestamp ${video_dir}cam.mp4
            read -p "Replay? [y/N] " replay
        done;

        read -p 'Does it look good? Confirm with y ' confirmation
    done;
    echo $timestamp > ${video_dir}talk_end.txt
done
