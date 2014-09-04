
CFLAGS = -Wall -O0

DESTDIR=/usr/local

all: uio

uio: uio.c
	$(CC) $+ $(CFLAGS) -o uio
	
clean:
	rm -rf uio

install:
	install -d $(DESTDIR)/bin
	install ./uio $(DESTDIR)/bin/
	install ./foc_script.sh $(DESTDIR)/bin/

uninstall:
	rm -rf $(DESTDIR)/bin/uio
	rm -rf $(DESTDIR)/bin/foc_script.sh