########### CONFIGURATION ############

#Use geoip module?  true|false 
USE_GEOIP=true

#Use irc bot? true|false
USE_IRCBOT=true

#Sqlite3 support? true|false
USE_SQLITE3=true

#Mysql support? true|false
USE_MYSQL=true

######################################

### Tools
CXX=gcc
MV=mv
STRIP=


PLATFORM=$(shell uname -s)

#result file name
PLATFORM_SUFFIX=.i386
ifneq (,$(findstring x86_64,$(shell uname -a)))
PLATFORM_SUFFIX=.x86_64
endif
ifneq (,$(findstring amd64,$(shell uname -a)))
PLATFORM_SUFFIX=.x86_64
endif

SERVER_NAME=sauer_server
ifneq (,$(findstring MINGW,$(PLATFORM)))
SERVER_NAME=sauer_server$(PLATFORM_SUFFIX).exe
endif
ifneq (,$(findstring Linux,$(PLATFORM)))
SERVER_NAME=sauer_server$(PLATFORM_SUFFIX)
endif
ifneq (,$(findstring FreeBSD,$(PLATFORM)))
SERVER_NAME=sauer_server_freebsd$(PLATFORM_SUFFIX)
endif

### Folders, libraries, includes
ifneq (,$(findstring MINGW,$(PLATFORM)))
SERVER_INCLUDES+= -DSTANDALONE $(INCLUDES) -Iinclude
SERVER_LIBS= -Llib -lzdll -lenet -lws2_32 -lwinmm -lstdc++
else
SERVER_INCLUDES+= -DSTANDALONE $(INCLUDES)
SERVER_LIBS= -Lenet/.libs -L/usr/local/lib -lenet -lz -lstdc++
endif

ifeq ($(PLATFORM),SunOS)
SERVER_LIBS+= -lsocket -lnsl
endif

CXXFLAGS= -O0 -fomit-frame-pointer -Wall -fsigned-char -DSTANDALONE
override CXXFLAGS+= -g -DDEBUG # uncomment for debugging

ifeq (,$(findstring -g,$(CXXFLAGS)))
ifeq (,$(findstring -pg,$(CXXFLAGS)))
  STRIP=strip
endif
endif

INCLUDES= -Ishared -Iengine -Ifpsgame -Ienet/include -Imod -Imod/hashlib2plus/src 

SERVER_OBJS= \
	shared/crypto-standalone.o \
	shared/stream-standalone.o \
	shared/tools-standalone.o \
	engine/command-standalone.o \
	engine/server-standalone.o \
	fpsgame/server-standalone.o \
	mod/commandev-standalone.o \
	mod/commandhandler-standalone.o \
	mod/rconmod-standalone.o \
	mod/serverctrl-standalone.o \
	mod/remod-standalone.o \
	mod/cryptomod-standalone.o \
	mod/hashlib2plus/src/hl_md5-standalone.o \
	mod/hashlib2plus/src/hl_md5wrapper-standalone.o \
	mod/hashlib2plus/src/hl_sha1-standalone.o \
	mod/hashlib2plus/src/hl_sha1wrapper-standalone.o \
	mod/hashlib2plus/src/hl_sha256-standalone.o \
	mod/hashlib2plus/src/hl_sha256wrapper-standalone.o \
	mod/hashlib2plus/src/hl_sha2ext-standalone.o \
	mod/hashlib2plus/src/hl_sha384wrapper-standalone.o \
	mod/hashlib2plus/src/hl_sha512wrapper-standalone.o


### Options checks



#geoip
ifeq ($(USE_GEOIP),true)
override CXXFLAGS+= -DGEOIPDATADIR -DGEOIP
override INCLUDES+= -Imod/libGeoIP
override SERVER_OBJS+= mod/geoipmod-standalone.o mod/libGeoIP/GeoIP-standalone.o
endif
#end of geoip

#irc
ifeq ($(USE_IRCBOT),true)
override CXXFLAGS+= -DIRC
override SERVER_OBJS+= mod/irc-standalone.o
endif
#end of irc



#use db
ifeq ($(USE_SQLITE3),true)
override SERVER_OBJS+= mod/db-standalone.o
else 
ifeq ($(USE_MYSQL),true) 
override SERVER_OBJS+= mod/db-standalone.o
endif
endif
#end of use db



#sqlite3
ifeq ($(USE_SQLITE3),true)
override CXXFLAGS+= -DSQLITE3
override INCLUDES+= -Imod/sqlite3
#linux-only libs
ifeq ($(PLATFORM),Linux)
override SERVER_LIBS+= -ldl -lpthread
endif
override SERVER_OBJS+= mod/sqlite3/sqlite3-standalone.o mod/sqlite3-standalone.o
endif
#end of sqlite3



#mysql
ifeq ($(USE_MYSQL),true)
override CXXFLAGS+= -DUSE_MYSQL -DDBUG_OFF
override INCLUDES += -Imod/mysql/include -Imod/mysql/extlib/regex -Imod/mysql/mysys -Imod/mysql/vio

ifeq (,$(findstring MINGW,$(PLATFORM)))
override SERVER_LIBS += -lpthread -lm
else
override CXXFLAGS += -DNO_OLDNAMES
override SERVER_LIBS += -lws2_32 
endif
MYSQL_STRINGS_DIR = strings
MYSQL_STRINGS_OBJS = bchange-standalone.o bcmp-standalone.o bfill-standalone.o bmove512-standalone.o bmove_upp-standalone.o \
				ctype-bin-standalone.o ctype-extra-standalone.o ctype-mb-standalone.o ctype-utf8-standalone.o ctype-latin1-standalone.o ctype-standalone.o ctype-simple-standalone.o \
				decimal-standalone.o dtoa-standalone.o int2str-standalone.o \
				is_prefix-standalone.o llstr-standalone.o longlong2str-standalone.o my_strtoll10-standalone.o my_vsnprintf-standalone.o r_strinstr-standalone.o \
				str2int-standalone.o str_alloc-standalone.o strcend-standalone.o strend-standalone.o strfill-standalone.o strmake-standalone.o strmov-standalone.o strnmov-standalone.o \
				strtol-standalone.o strtoll-standalone.o strtoul-standalone.o strtoull-standalone.o strxmov-standalone.o strxnmov-standalone.o xml-standalone.o \
				my_strchr-standalone.o strcont-standalone.o strinstr-standalone.o strnlen-standalone.o strappend-standalone.o
MYSQL_REGEX_DIR = extlib/regex
MYSQL_REGEX_OBJS = debug-standalone.o regcomp-standalone.o regerror-standalone.o regexec-standalone.o regfree-standalone.o reginit-standalone.o split-standalone.o
MYSQL_MYSYS_DIR = mysys
MYSQL_MYSYS_OBJS = array-standalone.o charset-def-standalone.o charset-standalone.o checksum-standalone.o default-standalone.o default_modify-standalone.o \
			errors-standalone.o hash-standalone.o list-standalone.o md5-standalone.o mf_brkhant-standalone.o mf_cache-standalone.o mf_dirname-standalone.o mf_fn_ext-standalone.o \
			mf_format-standalone.o mf_getdate-standalone.o mf_iocache-standalone.o mf_iocache2-standalone.o mf_keycache-standalone.o my_safehash-standalone.o \
			mf_keycaches-standalone.o mf_loadpath-standalone.o mf_pack-standalone.o mf_path-standalone.o mf_qsort-standalone.o mf_qsort2-standalone.o \
			mf_radix-standalone.o mf_same-standalone.o mf_sort-standalone.o mf_soundex-standalone.o mf_strip-standalone.o mf_arr_appstr-standalone.o mf_tempdir-standalone.o \
			mf_tempfile-standalone.o mf_unixpath-standalone.o mf_wcomp-standalone.o mf_wfile-standalone.o mulalloc-standalone.o my_access-standalone.o \
			my_aes-standalone.o my_alarm-standalone.o my_alloc-standalone.o my_append-standalone.o my_bit-standalone.o my_bitmap-standalone.o my_chmod-standalone.o my_chsize-standalone.o \
			my_clock-standalone.o my_compress-standalone.o my_conio-standalone.o my_copy-standalone.o my_create-standalone.o my_delete-standalone.o \
			my_div-standalone.o my_error-standalone.o my_file-standalone.o my_fopen-standalone.o my_fstream-standalone.o my_gethostbyname-standalone.o \
			my_gethwaddr-standalone.o my_getopt-standalone.o my_getsystime-standalone.o my_getwd-standalone.o my_init-standalone.o \
			my_lib-standalone.o my_lock-standalone.o my_lockmem-standalone.o my_malloc-standalone.o my_messnc-standalone.o my_dup-standalone.o \
			my_mkdir-standalone.o my_mmap-standalone.o my_net-standalone.o my_once-standalone.o my_open-standalone.o my_pread-standalone.o my_pthread-standalone.o \
			my_quick-standalone.o my_read-standalone.o my_realloc-standalone.o my_redel-standalone.o my_rename-standalone.o my_seek-standalone.o my_sleep-standalone.o \
			my_static-standalone.o my_symlink-standalone.o my_symlink2-standalone.o my_sync-standalone.o my_thr_init-standalone.o my_wincond-standalone.o \
			my_winerr-standalone.o my_winfile-standalone.o \
			my_windac-standalone.o my_winthread-standalone.o my_write-standalone.o ptr_cmp-standalone.o queues-standalone.o  \
			rijndael-standalone.o safemalloc-standalone.o sha1-standalone.o string-standalone.o thr_alarm-standalone.o thr_lock-standalone.o thr_mutex-standalone.o \
			thr_rwlock-standalone.o tree-standalone.o typelib-standalone.o my_vle-standalone.o base64-standalone.o my_memmem-standalone.o my_getpagesize-standalone.o \
			my_atomic-standalone.o my_getncpus-standalone.o my_rnd-standalone.o \
			my_uuid-standalone.o wqueue-standalone.o  my_port-standalone.o
MYSQL_VIO_DIR = vio
MYSQL_VIO_OBJS = vio-standalone.o viosocket-standalone.o
MYSQL_LIBMYSQL_DIR = libmysql
MYSQL_LIBMYSQL_OBJS = client-standalone.o errmsg-standalone.o get_password-standalone.o libmysql-standalone.o my_time-standalone.o net_serv-standalone.o pack-standalone.o password-standalone.o

override SERVER_OBJS += $(foreach v,$(MYSQL_STRINGS_OBJS),mod/mysql/$(MYSQL_STRINGS_DIR)/$(v))
override SERVER_OBJS += $(foreach v,$(MYSQL_REGEX_OBJS),mod/mysql/$(MYSQL_REGEX_DIR)/$(v))
override SERVER_OBJS += $(foreach v,$(MYSQL_MYSYS_OBJS),mod/mysql/$(MYSQL_MYSYS_DIR)/$(v))
override SERVER_OBJS += $(foreach v,$(MYSQL_VIO_OBJS),mod/mysql/$(MYSQL_VIO_DIR)/$(v))
override SERVER_OBJS += $(foreach v,$(MYSQL_LIBMYSQL_OBJS),mod/mysql/$(MYSQL_LIBMYSQL_DIR)/$(v))
override SERVER_OBJS += mod/mysql-standalone.o
endif
#end of mysql



default: all

all: revision server

revision:
SVNVERSION= $(shell svnversion -cn . 2>/dev/null | sed -e "s/.*://" -e "s/\([0-9]*\).*/\1/" | grep "[0-9]") 
ifneq "$(SVNVERSION)" " "
override CXXFLAGS+= -DREMOD_VERSION="\"SVN build rev: $(SVNVERSION)\""
endif

enet/Makefile:
	cd enet; chmod +x configure; ./configure --enable-shared=no --enable-static=yes
	
libenet: enet/Makefile
	$(MAKE)	-C enet/ all

clean-enet: enet/Makefile
	$(MAKE) -C enet/ clean

clean:
	-$(RM) $(SERVER_OBJS) 

%.h.gch: %.h
	$(CXX) $(CXXFLAGS) -o $@.tmp $(subst .h.gch,.h,$@)
	$(MV) $@.tmp $@

%-standalone.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $(subst -standalone.o,.cpp,$@) 

%-standalone.o: %.c
	$(CXX) $(CXXFLAGS) -c -o $@ $(subst -standalone.o,.c,$@)	


$(SERVER_OBJS): CXXFLAGS += $(SERVER_INCLUDES)

ifneq (,$(findstring MINGW,$(PLATFORM)))
server: $(SERVER_OBJS)
	$(CXX) $(CXXFLAGS) -o $(SERVER_NAME) $(SERVER_OBJS) $(SERVER_LIBS)

else
server:	libenet $(SERVER_OBJS)
	$(CXX) $(CXXFLAGS) -o $(SERVER_NAME) $(SERVER_OBJS) $(SERVER_LIBS)  
	
ifneq (,$(STRIP))
	$(STRIP) ../bin_unix/$(SERVER_NAME)
endif
endif
