#!/bin/sh

# TODO set config values
cover_src=070-deskew/465.jpg

magick "$cover_src" -scale 50% -quality 50% cover.avif
