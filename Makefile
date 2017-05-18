#
# NVM Express Compliance Suite
# Copyright (c) 2011, Intel Corporation.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
#

# Modify the Makefile to point to Linux build tree.
KDIR:=/lib/modules/$(DIST)/build/
CDIR:=/usr/src/linux-source-3.5.0-generic/debian/scripts/
SOURCE:=$(shell pwd)
DRV_NAME:=dnvme

# QEMU_ON should be used when running the driver within QEMU, which forces
# dnvme to convert 8B writes to 2 4B writes patchin a QEMU deficiency
#QEMU_ON:=-DQEMU

# Introduces more logging in /var/log/messages; enhances debug but slows down
#DBG_ON:=-g -DDEBUG

EXTRA_CFLAGS+=-Wall $(QEMU_ON) $(DBG_ON) -I$(PWD)/

SOURCES := \
	dnvme_reg.c \
	sysdnvme.c \
	dnvme_ioctls.c \
	dnvme_sts_chk.c \
	dnvme_queue.c \
	dnvme_cmds.c \
	dnvme_ds.c \
	dnvme_irq.c

SRCDIR?=./src

obj-m := dnvme.o
dnvme-objs += sysdnvme.o dnvme_ioctls.o dnvme_reg.o dnvme_sts_chk.o dnvme_queue.o dnvme_cmds.o dnvme_ds.o dnvme_irq.o

# By default, we try to compile the modules for the currently running
# kernel.  But it's the first approximation, as we will re-read the
# version from the kernel sources.
KVERS_UNAME ?= $(shell uname -r)

# KBUILD is the path to the Linux kernel build tree.  It is usually the
# same as the kernel source tree, except when the kernel was compiled in
# a separate directory.
KBUILD ?= $(shell readlink -f /lib/modules/$(KVERS_UNAME)/build)

ifeq (,$(KBUILD))
$(error Kernel build tree not found - please set KBUILD to configured kernel)
endif

KCONFIG := $(KBUILD)/.config
ifeq (,$(wildcard $(KCONFIG)))
$(error No .config found in $(KBUILD), please set KBUILD to configured kernel)
endif

ifneq (,$(wildcard $(KBUILD)/include/linux/version.h))
ifneq (,$(wildcard $(KBUILD)/include/generated/uapi/linux/version.h))
$(error Multiple copies of version.h found, please clean your build tree)
endif
endif

# Kernel Makefile doesn't always know the exact kernel version, so we
# get it from the kernel headers instead and pass it to make.
VERSION_H := $(KBUILD)/include/generated/utsrelease.h
ifeq (,$(wildcard $(VERSION_H)))
VERSION_H := $(KBUILD)/include/linux/utsrelease.h
endif
ifeq (,$(wildcard $(VERSION_H)))
VERSION_H := $(KBUILD)/include/linux/version.h
endif
ifeq (,$(wildcard $(VERSION_H)))
$(error Please run 'make modules_prepare' in $(KBUILD))
endif

KVERS := $(shell sed -ne 's/"//g;s/^\#define UTS_RELEASE //p' $(VERSION_H))

ifeq (,$(KVERS))
$(error Cannot find UTS_RELEASE in $(VERSION_H), please report)
endif

include $(KCONFIG)

all:
	$(MAKE) -C $(KBUILD) M=$(SRC_DIR) modules

clean:
	$(MAKE) -C $(KBUILD) M=$(SRC_DIR) clean
