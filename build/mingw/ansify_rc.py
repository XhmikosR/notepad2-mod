## Designed with <3 by dejbug.

import argparse
import codecs
import contextlib
import itertools
import os, os.path
import sys

DEFAULT_DECODER = "utf16"
DEFAULT_ENCODER = "mbcs"

class Error(Exception): pass

class InvalidArgs(Error): pass

class ConversionFail(Error):
	def __init__(self, decoder, encoder, culprit, line_index, e):
		super(ConversionFail, self).__init__("%s error at '%s -> %s' conversion trial on line %d : %s" % (culprit, decoder, encoder, line_index, e))

def main(argv):
	
	try: parser, args = parse_args(argv)
	except InvalidArgs, e: 
		print "! invalid arguments : %s" % e
		exit(1)

	try:
		with autoclosing_open(args.outpath, "wb") as outfile:
			for line in convert_file(args.inpath, args.decoder, args.encoder):
				outfile.write(line)
	except ConversionFail, e:
		print >>sys.stderr, "! couldn't convert file : %s" % e
		exit(2)

def parse_args(argv):
	info = "Re-encode a file."
	note = "Some common codecs to try: utf32, utf16, utf8, mbcs (ansi, only windows), cp1252, cp850, latin1, ascii."
	p = argparse.ArgumentParser(description=info, epilog=note)
	p.add_argument("inpath", help="path to .rc file")
	p.add_argument("-o", "--outpath", help="path to write output to")
	p.add_argument("-f", "--force", help="force overwrite of extant outpath", action="store_true")
	p.add_argument("-d", "--decoder", help="codec to decode with (default: %s)" % DEFAULT_DECODER, default=DEFAULT_DECODER)
	p.add_argument("-e", "--encoder", help="codec to encode into (default: %s)" % DEFAULT_ENCODER, default=DEFAULT_ENCODER)
	p.add_argument("-v", "--verbose", help="print more stuff (to stderr)")
	p.add_argument("--module-relative-paths", help="paths are relative to location of this python file", action="store_true")
	a = p.parse_args(argv[1:])
	validate_and_adjust_args(p, a)
	return p, a

def validate_and_adjust_args(parser, args):
	
	args.original_inpath = args.inpath
	args.original_outpath = args.outpath
	
	if args.module_relative_paths:
		args.inpath = make_module_relative_path(args.inpath)
	else:
		args.inpath = os.path.abspath(args.inpath)
		
	if not os.path.isfile(args.inpath):
		raise InvalidArgs("no infile found at '%s' (user passed '%s')%s" % (args.inpath, args.original_inpath, "" if args.module_relative_paths else "did you forget the --module-relative-paths flag?"))
	
	if args.outpath:
		if args.module_relative_paths:
			args.outpath = make_module_relative_path(args.outpath)
		else:
			args.outpath = os.path.abspath(args.outpath)
			
		if os.path.exists(args.outpath):
			if not os.path.isfile(args.outpath):
				raise InvalidArgs("outpath exists but is not a file")
			elif not args.force:
				raise InvalidArgs("outpath exists; add -f to force overwrite")
	
	if not args.decoder: args.encoder = DEFAULT_DECODER
	if not args.encoder: args.encoder = DEFAULT_ENCODER
	
	def translate_codec(codec):
		_codec = codec.lower()
		if "ansi" == _codec: return "mbcs"
		return codec
		
	args.encoder = translate_codec(args.encoder)
	args.decoder = translate_codec(args.decoder)
	
	try: codecs.getencoder(args.encoder)
	except LookupError:
		raise InvalidArgs("no such encoder: '%s'" % args.encoder)
		
	try: codecs.getdecoder(args.decoder)
	except LookupError:
		raise InvalidArgs("no such decoder: '%s'" % args.decoder)

def make_module_relative_path(rel_path, argv=None):
	if argv: return make_path(dir_from_path(argv[0]), rel_path)
	else: return make_path(dir_from_path(__file__), rel_path)

def make_path(root, rel_path):
	return os.path.abspath(os.path.join(root, rel_path))

def dir_from_path(path):
	return os.path.split(path)[0]

@contextlib.contextmanager
def autoclosing_open(path, mode):
	if path:
		with open(path, "wb") as file:
			yield file
	else:
		yield sys.stdout

def convert_file(inpath, decoder, encoder):
	line_index = 1
	try:
		with codecs.open(inpath, "rb", decoder) as file:
			for line_index, line in enumerate(file, start=1):
				yield convert_line(line, encoder)
	except UnicodeDecodeError, e:
		raise ConversionFail(decoder, encoder, "decoder", line_index, e)
	except UnicodeEncodeError, e:
		raise ConversionFail(decoder, encoder, "encoder", line_index, e)

def convert_line(text, encoder):
	return text.encode(encoder)
	
def exception_to_string(e):
	return "[%s] %s" % (type(e).__name__, str(e))

if "__main__" == __name__:
	main(sys.argv)
