#!/bin/sh
ldc2 *.d -ofperiod_dragon pkg-config --static --libs allegro_ttf-static-5.1 allegro_acodec-static-5.1 allegro_primitives-static-5.1 allegro_image-static-5.1 | sed -e 's/-[lL]/-L&/g'
