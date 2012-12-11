BASE_DIR       = $(shell pwd)
SOURCE_DIR     = $(BASE_DIR)/src
BUILD_DIR      = $(BASE_DIR)/build
HOST_DIR       = $(BASE_DIR)/host

CURL_PACKAGE   = curl-7.28.1.tar.gz
ZLIB_PACKAGE   = zlib-1.2.7.tar.gz
OPENSSL_PACKAGE= openssl-1.0.1c.tar.gz

CROSS_COMPILE ?= $(HOME)/CodeSourcery/Sourcery_G++_Lite/bin/arm-none-linux-gnueabi-
AR             = $(CROSS_COMPILE)ar
CC             = $(CROSS_COMPILE)gcc
CXX            = $(CROSS_COMPILE)g++
LD             = $(CROSS_COMPILE)g++
NM             = $(CROSS_COMPILE)nm
RANLIB         = $(CROSS_COMPILE)ranlib
CFLAGS         = -mcpu=arm926ej-s
CXXFLAGS       = -mcpu=arm926ej-s
TAR            = /bin/tar

curl:
	$(TAR) xvzf $(SOURCE_DIR)/$(CURL_PACKAGE) -C $(BUILD_DIR)
	cd $(BUILD_DIR)/$(firstword $(subst .tar., ,$(CURL_PACKAGE))) && \
	CC=$(CC) CFLAGS="$(CFLAGS)" \
	AR=$(AR) RANLIB=$(RANLIB) \
	PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
	./configure --prefix=$(HOST_DIR) --with-gnu-ld --host=arm-none-linux-gnueabi \
	--disable-http --disable-ftp --disable-file --disable-ldap --disable-rtsp \
	--disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 \
	--disable-imap --disable-smtp --disable-sspi --disable-crypto-auth --disable-cookies \
	--without-ldap-lib --without-lber-lib --without-krb4 --without-spnego \
	--without-gssapi --with-ssl --with-zlib=$(HOST_DIR) \
	--without-gnutls --without-polarssl --without-nss --without-ca-bundle \
	--without-libssh2 --without-librtmp --without-libidn && \
	$(MAKE) && \
	$(MAKE) install


zlib:
	$(TAR) xvzf $(SOURCE_DIR)/$(ZLIB_PACKAGE) -C $(BUILD_DIR)
	cd $(BUILD_DIR)/$(firstword $(subst .tar., ,$(ZLIB_PACKAGE))) && \
	CC=$(CC) CFLAGS="$(CFLAGS)" \
	AR=$(AR) RANLIB=$(RANLIB) \
	./configure --prefix=$(HOST_DIR) && \
	$(MAKE) && \
	$(MAKE) install

openssl:
	$(TAR) xvzf $(SOURCE_DIR)/$(OPENSSL_PACKAGE) -C $(BUILD_DIR)
	cd $(BUILD_DIR)/$(firstword $(subst .tar., ,$(OPENSSL_PACKAGE))) && \
	AR=$(AR) NM=$(NM) \
	./Configure --prefix=$(HOST_DIR) zlib-dynamic "linux-arm926ej-s":"$(CC):$(CFLAGS) -DTERMIO -O3 -Wall -I$(HOST_DIR)/include::-D_REENTRANT::-L$(HOST_DIR)/lib -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR::bn_asm.o armv4-mont.o::aes_cbc.o aes-armv4.o:::sha1-armv4-large.o sha256-armv4.o sha512-armv4.o:::::::void:dlfcn:linux-shared:-fPIC::.so.1.0.0":$(RANLIB):: && \
	$(MAKE) && \
	$(MAKE) install

