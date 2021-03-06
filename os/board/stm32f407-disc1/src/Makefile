###########################################################################
#
# Copyright 2018 Samsung Electronics All Rights Reserved.
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
############################################################################
############################################################################
# os/board/stm32f407-disc1/src/Makefile
#
#   Copyright (C) 2011-2013 Gregory Nutt. All rights reserved.
#   Author: Gregory Nutt <gnutt@nuttx.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name NuttX nor the names of its contributors may be
#    used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
############################################################################

-include $(TOPDIR)/Make.defs

CFLAGS += -I$(TOPDIR)/sched

ASRCS =
AOBJS = $(ASRCS:.S=$(OBJEXT))

CSRCS = stm32_boot.c stm32_bringup.c stm32_spi.c
ifeq ($(CONFIG_ENC28J60),y)
CSRCS += up_enc28j60.c
endif

ifeq ($(CONFIG_ARCH_LEDS),y)
CSRCS += stm32_autoleds.c
else
CSRCS += stm32_userleds.c
endif

ifeq ($(CONFIG_ARCH_BUTTONS),y)
CSRCS +=  stm32_buttons.c
endif

ifeq ($(CONFIG_STM32_OTGFS),y)
CSRCS += stm32_usb.c
endif

ifeq ($(CONFIG_STM32_SDIO),y)
CSRCS += stm32_sdio.c
endif

ifeq ($(CONFIG_PWM),y)
CSRCS += stm32_pwm.c
endif

ifeq ($(CONFIG_QENCODER),y)
CSRCS += stm32_qencoder.c
endif

ifeq ($(CONFIG_WATCHDOG),y)
CSRCS += stm32_watchdog.c
endif

ifeq ($(CONFIG_TASH_LIBRARY),y)
CSRCS += stm32_nsh.c
endif

ifeq ($(CONFIG_ARCH_CUSTOM_PMINIT),y)
CSRCS += stm32_pm.c
endif

ifeq ($(CONFIG_PM_BUTTONS),y)
CSRCS += stm32_pm_buttons.c
endif

ifeq ($(CONFIG_ARCH_IDLE_CUSTOM),y)
CSRCS += stm32_idle.c
endif

ifeq ($(CONFIG_STM32_FSMC),y)
CSRCS += stm32_extmem.c

ifeq ($(CONFIG_LCD_SSD1289),y)
CSRCS += stm32_ssd1289.c
endif
endif

ifeq ($(CONFIG_LCD_UG2864AMBAG01),y)
CSRCS += stm32_ug2864ambag01.c
endif

ifeq ($(CONFIG_LCD_UG2864HSWEG01),y)
CSRCS += stm32_ug2864hsweg01.c
endif

COBJS = $(CSRCS:.c=$(OBJEXT))

SRCS = $(ASRCS) $(CSRCS)
OBJS = $(AOBJS) $(COBJS)

ARCH_SRCDIR = $(TOPDIR)/arch/$(CONFIG_ARCH)/src
ifeq ($(CONFIG_WINDOWS_NATIVE),y)
  CFLAGS += -I$(ARCH_SRCDIR)\chip -I$(ARCH_SRCDIR)\common -I$(ARCH_SRCDIR)\armv7-m
else
ifeq ($(WINTOOL),y)
  CFLAGS += -I "${shell cygpath -w $(ARCH_SRCDIR)/chip}" \
			-I "${shell cygpath -w $(ARCH_SRCDIR)/common}" \
			-I "${shell cygpath -w $(ARCH_SRCDIR)/armv7-m}"
else
  CFLAGS += -I$(ARCH_SRCDIR)/chip -I$(ARCH_SRCDIR)/common -I$(ARCH_SRCDIR)/armv7-m
endif
endif

all: libboard$(LIBEXT)

$(AOBJS): %$(OBJEXT): %.S
	$(call ASSEMBLE, $<, $@)

$(COBJS) $(LINKOBJS): %$(OBJEXT): %.c
	$(call COMPILE, $<, $@)

libboard$(LIBEXT): $(OBJS)
	$(call ARCHIVE, $@, $(OBJS))

.depend: Makefile $(SRCS)
	$(Q) $(MKDEP) $(CC) -- $(CFLAGS) -- $(SRCS) >Make.dep
	$(Q) touch $@

depend: .depend

clean:
	$(call DELFILE, libboard$(LIBEXT))
	$(call CLEAN)

distclean: clean
	$(call DELFILE, Make.dep)
	$(call DELFILE, .depend)

-include Make.dep
