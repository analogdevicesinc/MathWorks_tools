
CFLAGS=-std=c99 -pedantic -Wall -D_POSIX_SOURCE
DEPS = mac.h reg.h
OBJ = modemd.o mac.o test_dma.o reg.o
prefix=/usr/local

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $< 

modemd: $(OBJ)
	$(CC) $(CFLAGS) -pthread -o $@ mac.o modemd.o -lm

test_dma: $(OBJ)
	$(CC) $(CFLAGS) -pthread -o $@ mac.o reg.o test_dma.o -lm

install:
	install -m 0755 modemd $(prefix)/bin
	install -m 0777 restart_modem_gui.sh $(prefix)/bin
	install -m 0444 modem_filter.ftr $(prefix)/share/rfsom-box-gui
clean:
	rm -rf test_dma modemd *.o
