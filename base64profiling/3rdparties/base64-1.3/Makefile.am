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

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = po lib src doc tests

indent:
	indent src/base64.c tests/test-base64.c

ChangeLog:
	cvs2cl --fsf --FSF --usermap .cvsusers -I ChangeLog -I .cvs
	cat .cvscopying >> ChangeLog

htmldir = ../www-$(PACKAGE)
tag = $(PACKAGE)-`echo $(VERSION) | sed 's/\./-/g'`

release:
	cvs upd -p -r HEAD NEWS > /dev/null
	if cvs upd -p -r $(tag) NEWS > /dev/null; then false else true; fi
	rm -f ChangeLog && cvs upd ChangeLog
	cvs commit
	rm -f ChangeLog
	$(MAKE) ChangeLog distcheck
	cvs commit -m "" ChangeLog
	cvs rtag $(tag) $(PACKAGE)
	gpg -b $(distdir).tar.gz
	gpg --verify $(distdir).tar.gz.sig
	cp -v $(distdir).tar.gz{,.sig} $(htmldir)/releases/
	cd $(htmldir) && cvs add -kb releases/$(distdir).tar.gz{,.sig} && \
		cvs commit -m "Update." releases/
