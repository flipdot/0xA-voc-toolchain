import ffmpeg

intro = ffmpeg.input("intro.mp4")
intro = ffmpeg.filter(intro, "scale", 1920, 1080)

slides = ffmpeg.input("slides.mkv")
slides = ffmpeg.filter(slides, "scale", 1536, 864)

cam = ffmpeg.input("cam.mkv")
cam = ffmpeg.filter(cam, "scale", 480, 270)

bg = ffmpeg.input("cam.mkv")

bg_with_cam = ffmpeg.filter(
    [bg, cam], "overlay", "main_w-overlay_w", "main_h-overlay_h"
)

talk = ffmpeg.filter(
    [
        ffmpeg.filter([bg, cam], "overlay", "main_w-overlay_w", "main_h-overlay_h"),
        slides,
    ],
    "overlay",
)

output = ffmpeg.output(ffmpeg.concat(intro, talk), "output.mkv", vcodec='h264')
ffmpeg.run(output)
