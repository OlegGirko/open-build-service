include ../../Makefile.include
-include ../../Makefile.local

DATADIR = /usr/share
INSTDIR = $(DATADIR)/selinux/packages

TES := $(wildcard *.te)
PPS := $(TES:.te=.pp)
FCS := $(TES:.te=.fc)

.SUFFIXES: .pp .te .if .fc .fc.in

all: $(PPS)

clean:
	rm -rf $(PPS) $(FCS) tmp

%.fc: %.fc.in
	sed \
	    -e 's,@@OBS_BACKEND_PREFIX@@,$(OBS_BACKEND_PREFIX),' \
	    -e 's,@@OBS_BACKEND_DATA_DIR@@,$(OBS_BACKEND_DATA_DIR),' \
	    -e 's,@@OBS_BACKEND_LOG_DIR@@,$(OBS_BACKEND_LOG_DIR),' \
	    -e 's,@@OBS_BACKEND_SERVICE_LOG_DIR@@,$(OBS_BACKEND_SERVICE_LOG_DIR),' \
	    -e 's,@@OBS_API_PREFIX@@,$(OBS_API_PREFIX),' \
	    -e 's,@@OBS_API_LOG_DIR@@,$(OBS_API_LOG_DIR),' \
	    < $*.fc.in > $*.fc

# Don't include /usr/share/selinux/devel/Makefile
# because it has its own rule to generate *.fc files
# that overrides our one.
%.pp: %.te %.fc %.if
	make -f /usr/share/selinux/devel/Makefile $@

install: $(PPS)
	install -d -m 755 $(DESTDIR)$(INSTDIR)
	install -D -m 644 $(PPS) $(DESTDIR)$(INSTDIR)
