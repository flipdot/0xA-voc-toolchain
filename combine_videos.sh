#!/bin/bash

ffmpeg -i test_intro_rec.mp4 -i test_bg_rec.mp4 -i test_screen_rec.mp4 -i test_vid_rec.mp4 -i test_outro_rec.mp4 -filter_complex \
    "
    [2:v]
        scale=1536:864
    [slides];
    [3:v]
        scale=480:270
    [cam];
    [4:v]
        fade=
            t=in:
            alpha=1,
        setpts=PTS-STARTPTS+20/TB
    [outro];
    [1:v][cam]
        overlay=
           x=main_w-overlay_w:
           y=main_h-overlay_h
    [bg_with_cam];
    [bg_with_cam][slides]
        overlay
    [talk];
    [0:v][talk]
        overlay
    [intro_with_talk];
    [intro_with_talk][outro]
        overlay
    [v]
    " \
    -map "[v]" test_output.mp4
