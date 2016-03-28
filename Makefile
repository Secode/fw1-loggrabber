# Change the following variables according to your system environment
GCC_PREFIX = /usr
CC_CMD = gcc
LD_CMD = gcc
CC = $(GCC_PREFIX)/bin/$(CC_CMD)
LD = $(GCC_PREFIX)/bin/$(LD_CMD)
PKG_DIR = OPSEC/pkg_rel/
INSTALL_PREFIX = /usr/local/fw1-loggrabber

EXE_NAME = fw1-loggrabber
OBJ_FILES = thread.o queue.o fw1-loggrabber.o

SYSCONFDIR=${INSTALL_PREFIX}/etc
BINDIR=${INSTALL_PREFIX}/bin
MANDIR=${INSTALL_PREFIX}/man
TEMPDIR=/tmp

LIB_DIR = $(PKG_DIR)/lib/release.static
STATIC_LIBS = \
	-lopsec \
	-lsicauth -lsic \
	-lcp_policy \
	-lskey \
	-lndb \
	-lckpssl -lcpcert \
	-lcpcryptutil -lcpprng \
	-lcpbcrypt -lcpca \
	-lasn1cpp \
	-lcpopenssl \
	-lAppUtils -lEventUtils \
	-lEncode -lComUtils \
	-lResolve -lDataStruct \
	-lOS \
	-lcpprod50 

LIBS = -lpthread -lresolv -ldl -lnsl -lelf -lstdc++
CFLAGS += -m32 -g -Wall -fpic -I$(PKG_DIR)/include -DLINUX -DUNIXOS=1 -DDEBUG

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $*.c

$(EXE_NAME): $(OBJ_FILES)
	$(LD) $(CFLAGS) -L$(LIB_DIR) -o $@ $(OBJ_FILES) $(STATIC_LIBS) $(LIBS)

install:
	@echo
	@echo "Installing FW1-Loggrabber to ${INSTALL_PREFIX}:"
	@echo
	install -v -d -o root -g root -m 755 ${BINDIR}
	install -v -d -o root -g root -m 755 ${SYSCONFDIR}
	install -v -d -o root -g root -m 755 ${MANDIR}/man1
	install -v -o root -g root -m 755 -p fw1-loggrabber ${BINDIR}/fw1-loggrabber
	install -v -o root -g root -m 644 -p fw1-loggrabber.conf ${SYSCONFDIR}/fw1-loggrabber.conf-sample
	install -v -o root -g root -m 644 -p lea.conf ${SYSCONFDIR}/lea.conf-sample
	install -v -o root -g root -m 644 -p fw1-loggrabber.1 ${MANDIR}/man1/fw1-loggrabber.1
	@echo
	@echo "Installation complete! Please declare the following environment variables in your shell configuration file:"
	@echo
	@echo "  LOGGRABBER_CONFIG_PATH=${SYSCONFDIR}"
	@echo "  export LOGGRABBER_CONFIG_PATH"
	@echo "  LOGGRABBER_TEMP_PATH=${TEMPDIR}"
	@echo "  export LOGGRABBER_TEMP_PATH"
	@echo

deb:
	@echo "Building .deb package"
	@echo "installing to fake root"
	mkdir fakeroot
	install -v -d fakeroot/usr/bin
	install -v -d fakeroot/etc/fw1-loggrabber
	install -v -d fakeroot/usr/share/man/man1
	install -v -m 755 -p OPSEC/linux30/opsec_pull_cert fakeroot/usr/bin/opsec_pull_cert
	install -v -m 755 -p OPSEC/linux30/opsec_putkey fakeroot/usr/bin/opsec_putkey
	install -v -m 755 -p fw1-loggrabber fakeroot/usr/bin/fw1-loggrabber
	install -v -p fw1-loggrabber.conf fakeroot/etc/fw1-loggrabber/fw1-loggrabber.conf-sample
	install -v -p lea.conf fakeroot/etc/fw1-loggrabber/lea.conf-sample
	install -v -m 644 -p fw1-loggrabber.1 fakeroot/usr/share/man/man1/fw1-loggrabber.1
	@echo
	fpm -s dir -d libstdc++5:i386 -d libpam0g:i386 -t deb --name fw1loggrabber --version 2.0 -C fakeroot
	rm -rf fakeroot
	@echo 

rpm:
	@echo "Building .rpm package"
	@echo "installing to fake root"
	mkdir fakeroot
	install -v -d fakeroot/usr/bin
	install -v -d fakeroot/etc/fw1-loggrabber
	install -v -d fakeroot/usr/share/man/man1
	install -v -m 755 -p OPSEC/linux30/opsec_pull_cert fakeroot/usr/bin/opsec_pull_cert
	install -v -m 755 -p OPSEC/linux30/opsec_putkey fakeroot/usr/bin/opsec_putkey
	install -v -m 755 -p fw1-loggrabber fakeroot/usr/bin/fw1-loggrabber
	install -v -p fw1-loggrabber.conf fakeroot/etc/fw1-loggrabber/fw1-loggrabber.conf-sample
	install -v -p lea.conf fakeroot/etc/fw1-loggrabber/lea.conf-sample
	install -v -m 644 -p fw1-loggrabber.1 fakeroot/usr/share/man/man1/fw1-loggrabber.1
	@echo
	fpm -s dir -d "compat-libstdc++-33(x86-32)" -d "pam(x86-32)" -t rpm --name fw1loggrabber --version 2.0 -C fakeroot
	rm -rf fakeroot
	@echo 

clean:
	rm -f *.o $(EXE_NAME)
	rm -rf fakeroot
	rm -f *.deb
