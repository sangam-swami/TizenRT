###########################################################################
#
# Copyright 2019 Samsung Electronics All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
#
###########################################################################
include $(TOPDIR)/.config
include $(TOPDIR)/Make.defs

CXXEXT ?= .cxx
EXTRA_LIBPATHS ?=
EXTRA_LIBS ?=
USERTESTLIB += $(LIBRARIES_DIR)$(DELIM)libcxx$(LIBEXT)
LINKLIBS = $(patsubst $(LIBRARIES_DIR)/%, %, $(USERLIBS))
USER_LIBPATHS = $(addprefix -L$(TOPDIR)$(DELIM),$(dir $(USERLIBS)))
LDLIBS = $(patsubst %.a, %, $(patsubst lib%,-l%,$(LINKLIBS)))

TINYARALIB = "$(TOPDIR)/../build/output/libraries"
USERSPACE = $(TOPDIR)/board/common/userspace/up_userspace

LDELFFLAGS += -Bstatic
LDLIBPATH += -L $(TINYARALIB)

LIBGCC = "${shell "$(CC)" $(ARCHCFLAGS) -print-libgcc-file-name}"
LDLIBS += $(LIBGCC)

OBJCOPY = $(CROSSDEV)objcopy
DEPPATH	= --dep-path .

ifeq ($(CONFIG_COMPRESSED_BINARY),y)
COMPRESSION_TYPE = $(CONFIG_COMPRESSION_TYPE)
BLOCK_SIZE = $(CONFIG_COMPRESSION_BLOCK_SIZE)
else
COMPRESSION_TYPE = 0
BLOCK_SIZE = 0
endif

APPDEFINE = ${shell $(TOPDIR)/tools/define.sh "$(CC)" __APP_BUILD__}

CSRCS += $(USERSPACE).c

COBJS = $(CSRCS:.c=$(OBJEXT))
CXXOBJS = $(CXXSRCS:.cxx=$(OBJEXT))

SRCS		= $(CSRCS) $(CXXSRCS)
OBJS		= $(COBJS) $(CXXOBJS)

prebuild:
	$(call DELFILE, $(USERSPACE)$(OBJEXT))

all: prebuild $(BIN)
.PHONY: prebuild clean depend install verify

$(COBJS): %$(OBJEXT): %.c
	@echo "CC: $<"
	$(Q) $(CC) $(APPDEFINE) -c $(CELFFLAGS) $< -o $@

$(CXXOBJS): %$(OBJEXT): %$(CXXEXT)
	@echo "CXX: $<"
	$(Q) $(CXX) $(APPDEFINE) -c $(CXXELFFLAGS) $< -o $@


$(BIN): $(OBJS)
	@echo "LD: $<"
	@echo "sangam dbg start:*******************************"
	@echo "LDLFAGS: $(LDELFFLAGS) LIBPATH : $(LDLIBPATH) archcrt0Obj : $(ARCHCRT0OBJ) extra lib path = $(EXTRA_LIBPATHS) OBJS : $^ userlib path: $(LDLIBS) extra libs: $(EXTRA_LIBS)"
	@echo "sangam dbg END+++++++++++++++++++++++++++++++++++:"
#	$(Q) $(LD) $(LDELFFLAGS) $(LDLIBPATH) -o $@ $(ARCHCRT0OBJ) $^ --start-group $(LDLIBS) --end-group
#	$(Q) $(LD) $(LDELFFLAGS) $(LDLIBPATH) $(EXTRA_LIBPATHS) -o $@ $(USER_LIBPATHS) $(ARCHCRT0OBJ) $^ --start-group $(LDLIBS) $(EXTRA_LIBS) --end-group
#	$(Q) $(LD) $(LDELFFLAGS) $(LDLIBPATH) $(USERTESTLIB) $(EXTRA_LIBPATHS) -o $@ $(USER_LIBPATHS) $(ARCHCRT0OBJ) $(USERTESTLIB) $^ --start-group $(LDLIBS) $(EXTRA_LIBS) $(USERTESTLIB) --end-group
	$(Q) $(LD) -o $@ $(ARCHCRT0OBJ) $(LDELFFLAGS) $(LDLIBPATH) $(EXTRA_LIBPATHS) $^ --start-group $(LDLIBS) $(EXTRA_LIBS) --end-group $(LIBGCC)

.depend: Makefile $(SRCS)

ifeq ($(filter %$(CXXEXT),$(SRCS)),)
	@$(MKDEP) $(ROOTDEPPATH) "$(CC)" -- $(CELFFLAGS) -- $(SRCS) >Make.dep
else
	@$(MKDEP) $(ROOTDEPPATH) "$(CXX)" -- $(CXXELFFLAGS) -- $(SRCS) >Make.dep
endif

	@touch $@

depend: .depend

clean:
	$(call DELFILE, $(BIN))
	$(call DELFILE, $(USER_BIN_DIR)/$(BIN))
	$(call CLEAN)

distclean: clean
	$(call DELFILE, Make.dep)
	$(call DELFILE, .depend)

install:
	$(Q) mkdir -p $(USER_BIN_DIR)
	$(Q) install $(BIN) $(USER_BIN_DIR)/$(BIN)
ifeq ($(CONFIG_ELF_EXCLUDE_SYMBOLS),y)
	$(Q) cp $(USER_BIN_DIR)/$(BIN) $(USER_BIN_DIR)/$(BIN)_dbg
	$(Q) $(OBJCOPY) --remove-section .comment $(USER_BIN_DIR)/$(BIN)
	$(Q) $(STRIP) -g $(USER_BIN_DIR)/$(BIN) -o $(USER_BIN_DIR)/$(BIN)
endif
	$(Q) $(TOPDIR)/tools/mkbinheader.py $(USER_BIN_DIR)/$(BIN) $(BIN_TYPE) $(KERNEL_VER) $(BIN) $(BIN_VER) $(DYNAMIC_RAM_SIZE) $(STACKSIZE) $(PRIORITY) $(COMPRESSION_TYPE) $(BLOCK_SIZE)
	$(Q) $(TOPDIR)/tools/mkchecksum.py $(USER_BIN_DIR)/$(BIN)

verify:
	$(Q) if [ "`nm -u $(BIN) | wc -l`" != "0" ]; then \
		echo "Undefined Symbols"; \
		nm -u -l $(BIN); \
		rm $(BIN); \
		exit 1; \
	fi
