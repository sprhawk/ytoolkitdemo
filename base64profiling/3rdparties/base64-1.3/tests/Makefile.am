## Process this file with automake to produce Makefile.in
# Copyright (C) 2004, 2005 Simon Josefsson.
#
# This file is part of Base64.
#
# Base64 is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# Base64 is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Base64; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

AM_CPPFLAGS = -I$(srcdir)/../lib -I../lib

LDADD = ../lib/libgnu.a

check_PROGRAMS = test-base64
dist_check_SCRIPTS = encode decode large
TESTS = $(check_PROGRAMS) $(dist_check_SCRIPTS)
