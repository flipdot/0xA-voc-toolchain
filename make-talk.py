import ffmpeg

WIDTH, HEIGHT = 1920, 1080
SLIDES_WIDTH, SLIDES_HEIGHT = 1536, 864

intro = ffmpeg.input("intro.mp4")
intro = (
    intro.filter("scale", WIDTH, HEIGHT).filter("setsar", 1).filter("format", "yuv420p")
)

slides = ffmpeg.input("slides.mkv")
slides = slides.filter("scale", SLIDES_WIDTH, SLIDES_HEIGHT)
# center the slides on a full-frame black canvas
slides = (
    slides.filter(
        "pad",
        WIDTH,
        HEIGHT,
        (WIDTH - SLIDES_WIDTH) // 2,
        (HEIGHT - SLIDES_HEIGHT) // 2,
    )
    .filter("setsar", 1)
    .filter("format", "yuv420p")
)

cam = ffmpeg.input("cam.mkv")
cam = cam.filter("scale", 480, 270)

talk = ffmpeg.filter([slides, cam], "overlay", "main_w-overlay_w", "main_h-overlay_h")

output = ffmpeg.output(ffmpeg.concat(intro, talk), "output.mkv", vcodec="h264")
ffmpeg.run(output)
