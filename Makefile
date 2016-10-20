GCC_PREFIX = /usr
CC_CMD = gcc
LD_CMD = gcc
CC = $(GCC_PREFIX)/bin/$(CC_CMD)
LD = $(GCC_PREFIX)/bin/$(LD_CMD)
PKG_DIR = OPSEC/pkg_rel/
INSTALL_PREFIX = /usr/local/fw1-loggrabber

EXE_NAME = fw1-loggrabber
OBJ_FILES = thread.o queue.o fw1-loggrabber.o

CFLAGS += -m32 -g -Wall -fpic -DLINUX -DUNIXOS=1 -DDEBUG
SYSTEM_LIBS = -lpthread -lresolv -ldl -lnsl -lelf -lstdc++ -lz

OPSEC_PKG_DIR = OPSEC_SDK/pkg_rel
OPSEC_INC_DIR = $(OPSEC_PKG_DIR)/include
OPSEC_LIB_DIR = $(OPSEC_PKG_DIR)/lib/release.dynamic
OPSEC_LIBS = \
	-lopsec \
	-lcpprod50 \
	-lsicauth \
	-lskey \
	-lfwsetdb \
	-lndb \
	-lsic \
	-lcp_policy \
	-lcpca \
	-lckpssl \
	-lcpcert \
	-lcpcryptutil \
	-lEncode \
	-lcpprng \
	-lProdUtils \
	-lcpbcrypt \
	-lcpopenssl \
	-lAppUtils \
	-lComUtils \
	-lResolve \
	-lEventUtils \
	-lDataStruct \
	-lOS

INSTALL_DIR = /usr/local/fw1-loggrabber
INSTALL_BIN_DIR=${INSTALL_DIR}/bin
INSTALL_ETC_DIR=${INSTALL_DIR}/etc
INSTALL_LIB_DIR=${INSTALL_DIR}/lib
TEMP_DIR=/tmp

%.o: %.c
	$(CC) $(CFLAGS) -I$(OPSEC_INC_DIR) -c -o $@ $*.c

$(EXE_NAME): $(OBJ_FILES)
	$(LD) $(CFLAGS) -L$(OPSEC_LIB_DIR) -o $@ $(OBJ_FILES) $(OPSEC_LIBS) $(SYSTEM_LIBS)

install:
	@echo
	@echo "Installing FW1-Loggrabber to ${INSTALL_DIR}:"
	@echo
	@install -v -o root -g root -m 755 -d ${INSTALL_BIN_DIR}
	@install -v -o root -g root -m 755 -d ${INSTALL_ETC_DIR}
	@install -v -o root -g root -m 755 -d ${INSTALL_LIB_DIR}
	@install -v -o root -g root -m 755 -p fw1-loggrabber ${INSTALL_BIN_DIR}/fw1-loggrabber
	@install -v -o root -g root -m 644 -p fw1-loggrabber.conf ${INSTALL_ETC_DIR}/fw1-loggrabber.conf-sample
	@install -v -o root -g root -m 644 -p lea.conf ${INSTALL_ETC_DIR}/lea.conf-sample
	@install -v -o root -g root -m 644 -t ${INSTALL_LIB_DIR} ${OPSEC_LIB_DIR}/*.so
	@echo
	@echo "Installation complete! Please declare the following environment variables in your shell configuration file:"
	@echo
	@echo "  LD_LIBRARY_PATH=\$$LD_LIBRARY_PATH:${INSTALL_LIB_DIR}"
	@echo "  export LD_LIBRARY_PATH"
	@echo "  LOGGRABBER_CONFIG_PATH=${INSTALL_ETC_DIR}"
	@echo "  export LOGGRABBER_CONFIG_PATH"
	@echo "  LOGGRABBER_TEMP_PATH=${TEMP_DIR}"
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
	fpm -s dir -d libstdc++6:i386 -d libpam0g:i386 -t deb --name fw1loggrabber --version 2.0 -C fakeroot
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
