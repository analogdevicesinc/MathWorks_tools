
CFLAGS=-std=c99 -pedantic -Wall -D_POSIX_SOURCE
DEPS = reg.h
OBJ = reg.o
prefix=/usr/local

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $< 

reg: $(OBJ)
	$(CC) $(CFLAGS) -pthread -o $@ reg.o -lm


install:
	install -m 0755 modemd $(prefix)/bin
	install -m 0777 restart_modem_gui.sh $(prefix)/bin
	install -m 0444 modem_filter.ftr $(prefix)/share/rfsom-box-gui
clean:
	rm -rf reg *.o
