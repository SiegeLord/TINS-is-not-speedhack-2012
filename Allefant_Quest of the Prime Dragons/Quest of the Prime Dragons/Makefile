FLAGS = `pkg-config allegro_image-static-5.1 allegro_primitives-static-5.1 allegro_ttf-static-5.1 allegro_acodec-static-5.1 allegro_color-static-5.1 --libs --cflags --static`

all:
	gcc -I c -std=gnu99 c/*.c c/*/*.c -o "Quest of the Prime Dragons.exe" ${FLAGS}
