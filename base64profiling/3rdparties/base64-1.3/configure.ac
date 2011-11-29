dnl Process this file with autoconf to produce a configure script.

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

AC_INIT([base64], [1.3], [simon@josefsson.org])

AM_INIT_AUTOMAKE

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION(0.14.1)

AC_PROG_CC
AC_PROG_RANLIB
AM_MISSING_PROG(HELP2MAN, help2man, $missing_dir)

AC_CHECK_HEADERS(unistd.h locale.h)
AC_CHECK_FUNCS(isatty)

gl_EARLY
gl_MODULES(base64 getopt closeout version-etc error xstrtol progname stdbool xalloc-die size_max quote)
gl_INIT

AC_CONFIG_FILES(Makefile po/Makefile.in doc/Makefile lib/Makefile \
                src/Makefile tests/Makefile)
AC_OUTPUT
