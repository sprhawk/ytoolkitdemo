/* Base64 encode/decode strings or files.
   Copyright (C) 2004, 2005 Simon Josefsson.

   This file is part of Base64.

   Base64 is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   Base64 is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Base64; see the file COPYING.  If not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA. */

/* Written by Simon Josefsson <simon@josefsson.org>.  */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>
#include <errno.h>
#include <getopt.h>

/* Get isatty. */
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif

#include "error.h"
#include "progname.h"
#include "xstrtol.h"
#include "closeout.h"
#include "version-etc.h"
#include "gettext.h"
#include "quote.h"
#include "quotearg.h"

#include "base64.h"

#ifdef HAVE_LOCALE_H
# include <locale.h>
#else
# define setlocale(Category, Locale)	/* empty */
#endif

#define _(String) gettext (String)

#define PROGRAM_NAME "base64"

#define AUTHOR "Simon Josefsson"

/* For long options that have no equivalent short option, use a
   non-character as a pseudo short option, starting with CHAR_MAX + 1.  */
enum
{
  LONG_WRAP_OPTION = CHAR_MAX + 1,
  IGNORE_GARBAGE_OPTION,
  QUIET_OPTION,
  /* These enum values cannot possibly conflict with the option
     values ordinarily used by commands, including CHAR_MAX + 1,
     etc.  Avoid CHAR_MIN - 1, as it may equal -1, the getopt
     end-of-options value.  */
  GETOPT_HELP_CHAR = (CHAR_MIN - 2),
  GETOPT_VERSION_CHAR = (CHAR_MIN - 3)
};

static const struct option long_options[] = {
  {"decode", no_argument, 0, 'd'},
  {"wrap", optional_argument, 0, LONG_WRAP_OPTION},
  {"ignore-garbage", no_argument, 0, IGNORE_GARBAGE_OPTION},
  {"quiet", no_argument, 0, 'q'},
  {"silent", no_argument, 0, QUIET_OPTION},
  {"help", no_argument, 0, GETOPT_HELP_CHAR},
  {"version", no_argument, 0, GETOPT_VERSION_CHAR},
  {NULL, 0, NULL, 0}
};

const char version_etc_copyright[] =
  /* Do *not* mark this string for translation.  */
  "Copyright (C) 2005 Simon Josefsson.";

static void
usage (int status)
{
  if (status != EXIT_SUCCESS)
    fprintf (stderr, _("Try `%s --help' for more information.\n"),
	     program_name);
  else
    {
      printf (_("\
Usage: %s [OPTION] [STRING]\n\
Base64 encode or decode STRING, or standard input, to standard output.\n\
\n"), program_name);
      fputs (_("\
  -w                    Wrap encoded lines after 76 characters.\n\
      --wrap[=COLS]     Wrap encoded lines after COLS character (default 76).\n\
\n\
  -d, --decode          Decode data.\n\
      --ignore-garbage  When decoding, ignore non-alphabet characters.\n\
\n\
"), stdout);
      fputs (_("\
  -q, --quiet, --silent\n\
                        Don't print initial banner.\n\
\n"), stdout);
      fputs (_("\
      --help            Display this help and exit.\n\
      --version         Output version information and exit.\n"), stdout);
      fputs (_("\
\n\
The data is encoded as described for the base64 alphabet in RFC 3548.\n\
Decoding require compliant input by default, use --ignore-garbage to\n\
attempt to recover from non-alphabet characters (such as newlines) in\n\
the encoded stream.\n"), stdout);
      printf (_("\nReport bugs to <%s>.\n"), PACKAGE_BUGREPORT);
    }

  exit (status);
}

#define BLOCKSIZE 3072
/* Ensure that BLOCKSIZE is a multiple of 3 and 4.  */
#if BLOCKSIZE % 12 != 0
#error "invalid BLOCKSIZE"
#endif
#define B64BLOCKSIZE BASE64_LENGTH (BLOCKSIZE)

static void
wrap_write (const char *buffer, size_t len,
	    size_t wrap_column, size_t * current_column, FILE * out)
{
  size_t written;

  if (wrap_column == 0)
    {
      /* Simple write. */
      if (fwrite (buffer, 1, len, stdout) < len)
	error (EXIT_FAILURE, errno, _("write error"));
    }
  else
    for (written = 0; written < len;)
      {
	size_t to_write = wrap_column - *current_column;

	if (written + to_write > len)
	  to_write = len - written;

	if (to_write == 0
	    ? (fputs ("\n", out) < 0)
	    : (fwrite (buffer + written, 1, to_write, stdout) < to_write))
	  error (EXIT_FAILURE, errno, _("write error"));

	written += to_write;
	*current_column = to_write;
      }
}

static void
do_encode (FILE * in, FILE * out, size_t wrap_column)
{
  size_t current_column = 0;
  char inbuf[BLOCKSIZE];
  char outbuf[B64BLOCKSIZE];
  size_t sum;

  do
    {
      size_t n;

      sum = 0;
      do
	{
	  n = fread (inbuf + sum, 1, BLOCKSIZE - sum, in);

	  if (n > BLOCKSIZE - sum)
	    error (EXIT_FAILURE, 0, _("read too much"));

	  sum += n;
	}
      while (!feof (in) && !ferror (in) && sum < BLOCKSIZE);

      if (sum > 0)
	{
	  /* Process input one block at a time.  Note that BLOCKSIZE %
	     3 == 0, so that no base64 pads will appear in output. */
	  base64_encode (inbuf, sum, outbuf, BASE64_LENGTH (sum));

	  wrap_write (outbuf, BASE64_LENGTH (sum), wrap_column,
		      &current_column, out);
	}
    }
  while (!feof (in) && !ferror (in) && sum == BLOCKSIZE);

  /* When wrapping, terminate last line. */
  if (wrap_column && fputs ("\n", out) < 0)
    error (EXIT_FAILURE, errno, _("write error"));

  if (ferror (in))
    error (EXIT_FAILURE, errno, _("read error"));
}

static void
do_decode (FILE * in, FILE * out, size_t ignore_garbage)
{
  char inbuf[B64BLOCKSIZE];
  char outbuf[BLOCKSIZE];
  size_t sum;

  do
    {
      bool ok;
      size_t n;

      sum = 0;
      do
	{
	  n = fread (inbuf + sum, 1, B64BLOCKSIZE - sum, in);

	  if (n > B64BLOCKSIZE - sum)
	    error (EXIT_FAILURE, 0, _("read too much"));

	  if (ignore_garbage)
	    {
	      size_t i;
	      for (i = 0; n > 0 && i < n;)
		if (isbase64 (inbuf[sum + i]))
		  i++;
		else
		  memmove (inbuf + sum + i, inbuf + sum + i + 1, --n - i);
	    }

	  sum += n;

	  if (ferror (in))
	    error (EXIT_FAILURE, errno, _("read error"));
	}
      while (sum < B64BLOCKSIZE && !feof (in));

      n = BLOCKSIZE;
      ok = base64_decode (inbuf, sum, outbuf, &n);

      if (fwrite (outbuf, 1, n, stdout) < n)
	error (EXIT_FAILURE, errno, _("write error"));

      if (!ok)
	error (EXIT_FAILURE, 0, _("invalid input"));
    }
  while (!feof (in));
}

int
main (int argc, char **argv)
{
  int opt;
  bool decode = false;
  bool ignore_garbage = false;
  size_t wrap_column = 0;
  bool quiet = false;

  /* Setting values of global variables.  */
  set_program_name (argv[0]);
  setlocale (LC_ALL, "");
  bindtextdomain (PACKAGE, LOCALEDIR);
  textdomain (PACKAGE);

  atexit (close_stdout);

  while ((opt = getopt_long (argc, argv, "dqw", long_options, NULL)) != -1)
    switch (opt)
      {
      case 'd':
	decode = true;
	break;

      case 'w':
      case LONG_WRAP_OPTION:
	if (optarg)
	  {
	    unsigned long int tmp_ulong;
	    if (xstrtoul (optarg, NULL, 0, &tmp_ulong, NULL) != LONGINT_OK
		|| SIZE_MAX < tmp_ulong || tmp_ulong == 0)
	      error (EXIT_FAILURE, 0, _("invalid wrap size: %s"),
		     quotearg (optarg));
	    wrap_column = tmp_ulong;
	  }
	else
	  wrap_column = 76;
	break;

      case IGNORE_GARBAGE_OPTION:
	ignore_garbage = true;
	break;

      case 'q':
      case QUIET_OPTION:
	quiet = true;
	break;

      case GETOPT_HELP_CHAR:
	usage (EXIT_SUCCESS);
	break;

      case GETOPT_VERSION_CHAR:
	version_etc (stdout, program_name, PACKAGE, VERSION, AUTHOR, NULL);
	exit (EXIT_SUCCESS);
	break;

      default:
	usage (EXIT_FAILURE);
      }

  if (argc - optind > 1)
    {
      error (0, 0, _("extra operand %s"), quote (argv[optind]));
      usage (EXIT_FAILURE);
    }

  if (!quiet
#ifdef HAVE_ISATTY
      && isatty (fileno (stdout))
#endif
      )
    {
      printf (_("%s %s\n\
Copyright 2004, 2005 Simon Josefsson.\n\
Base64 comes with NO WARRANTY, to the extent permitted by law.\n\
You may redistribute copies of Base64 under the terms of the GNU\n\
General Public License.  For more information about these matters,\n\
see the file named COPYING.\n"), PACKAGE, VERSION);
    }

  if (optind < argc)
    {
      const char *inbuf = argv[optind];
      size_t inlen = strlen (argv[optind]);
      char *out = NULL;
      size_t outlen = 0;

      if (decode)
	{
	  if (!base64_decode_alloc (inbuf, inlen, &out, &outlen))
	    error (EXIT_FAILURE, 0, _("invalid input"));
	  if (out == NULL)
	    xalloc_die ();

	  if (fwrite (out, 1, outlen, stdout) < outlen)
	    error (EXIT_FAILURE, errno, _("write error"));

	  free (out);
	}
      else
	{
	  size_t current_column = 0;

	  outlen = base64_encode_alloc (inbuf, inlen, &out);

	  if (out == NULL && outlen == 0 && inlen != 0)
	    error (EXIT_FAILURE, 0, "overlong input");
	  if (out == NULL)
	    xalloc_die ();

	  wrap_write (out, outlen, wrap_column, &current_column, stdout);

	  free (out);
	}
    }
  else
    {
      if (decode)
	do_decode (stdin, stdout, ignore_garbage);
      else
	do_encode (stdin, stdout, wrap_column);
    }

  if (fclose (stdin) == EOF)
    error (EXIT_FAILURE, errno, _("standard input"));

  exit (EXIT_SUCCESS);
}
