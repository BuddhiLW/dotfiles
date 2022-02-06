import vapoursynth as vs
core = vs.get_core()
core.std.AddBorders(video_in, 10, 10, 20, 20).set_output()
