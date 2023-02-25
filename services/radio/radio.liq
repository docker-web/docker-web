playlist = playlist(mode="random", reload=3600, getenv("MUSIC_DIR"))

silence = blank(id="blank")

radio = fallback(
  track_sensitive=false,
  [ playlist, silence ]
)

output.icecast(
  %mp3(bitrate=256, id3v2=true),
  name = "radio",
  description = getenv("RADIO_DESC"),
  mount = "live",
  password = getenv("ICECAST_SOURCE_PASSWORD"),
  host = "icecast",
  port = 8000,
  radio
)
