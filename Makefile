
HEADERS = gtkgcd.h TextWindow.h
SOURCES = main.m gtkgcd.c TextWindow.m

gtkgcddemo: $(HEADERS) $(SOURCES)
	clang -g `pkg-config --cflags --libs gtk+-2.0` -fblocks -fobjc-arc -fobjc-runtime=gnustep-1.8 -fobjc-nonfragile-abi -fconstant-string-class=NSConstantString -o gtkgcddemo $(SOURCES) -I/usr/local/include/GNUstepBase/ -L/usr/local/lib -std=c99 -lobjc -lgnustep-base -ldispatch
