#!/usr/bin/env python

import sys
from optparse import OptionParser
from array import array

def translate(text, to89t=True):
	substitutions = (
		('\\\\',		chr(12)),	# \\  -> bookmark
		('\\zeta',		chr(135)),
		('\\xi',		chr(138)),
		('\\x',			chr(215)),
		('\\union',		chr(28)),
		('\\tilde',		chr(126)),
		('\\theta',		chr(136)),
		('\\tau',		chr(144)),
		('\\subset',	chr(30)),
		('\\sigma',		chr(143)),
		('\\sum',		chr(142)),
		('\\rho',		chr(141)),
		('\\radix',		chr(168)),
		('\\Psi',		chr(146)),
		('\\pi',		chr(140)),
		('\\Pi',		chr(139)),
		('\\Phi',		chr(145)),
		('\\per',		chr(183)),
		('\\omega',		chr(148)),
		('\\Omega',		chr(147)),
		('\\not',		chr(172)),
		('\\mu',		chr(181)),
		('\\lambda',	chr(137)),
		('\\intersec',	chr(29)),
		('\\int',		chr(189)),
		('\\inf',		chr(190)),
		('\\in',		chr(31)),
		('\\i',			chr(151)),
		('\\gamma',		chr(131)),
		('\\Gamma',		chr(130)),
		('\\epsilon',	chr(134)),
		('\\e',			chr(150)),
		('\\delta',		chr(133)),
		('\\Delta',		chr(132)),
		('\\d',			chr(188)),
		('\\<-',		chr(21)),
		('\\->',		chr(22)),
		('\\+-',		chr(177)),
		('\\-',			chr(173)),
		('\\>=',		chr(158)),
		('\\!=',		chr(157)),
		('\\<=',		chr(156)),
		('\\beta',		chr(129)),
		('\\alfa',		chr(128))
	)
	if to89t == True:
		text = text.replace('\t', '  ') # tab -> double space
		for x in substitutions:
			text = text.replace(x[0], x[1])
	else:
		for x in substitutions:
			text = text.replace(x[1], x[0])
	return text

#==============================================================================

def to89t(path, text_, name89, path89):
	# Convert UNIX line endings to Windows line endings
	text_ = text_.replace(chr(13) + chr(10), chr(255))
	text_ = text_.replace(chr(10), chr(255))
	text_ = text_.replace(chr(255), chr(13) + chr(10))

	if text_[0] == chr(12):
		text_ = " " + text_
		
	text_ = translate(text_, to89t=True)
		
	header=array('c', [chr(0)]*90)
	text=array('c', text_)
	footer=array('c', [chr(0)]*4)
	
	while True:
		try:
			n = text.index(chr(10))
			if text[n+1] == chr(12):
				text.pop(n)
			else:
				text[n] = ' '
		except:
			break
	
	File89Length = len(text) + 4
	FileLength = File89Length + 90
	
	for i in range(0,7):
		header[i] = "**TI89**"[i]
	header[8] = chr(1)
	
	for i in range(0, len(path89)):
		header[10+i] = path89[i]
	header[58] = chr(1)
	header[60] = chr(82)
	
	for i in range(0, len(name89)):
		header[64+i] = name89[i]
	header[72] = chr(11)
	
	for i in range(0,4):
		header[76+i] = chr((FileLength // (256 ** i)) % 256)
	header[80] = chr(165)
	header[81] = chr(90)
	header[86] = chr(File89Length // 256)
	a = int(File89Length / 256)
	header[87] = chr(File89Length % 256)
	a += File89Length % 256
	header[89] = chr(1)
	
	footer[1] = chr(224)
	checksum=0
	for i in range(0, len(text)):
		checksum = (checksum + ord(text[i])) % 65536
	checksum = (checksum + a + 225) % 65536
	footer[2] = chr(int(checksum % 256))
	footer[3] = chr(int(checksum // 256))

	with open(path, 'wb') as file89t:
		header.tofile(file89t)
		text.tofile(file89t)
		footer.tofile(file89t)
	return

#==============================================================================

def totxt(path, text):
	text = text[90:-4]	# Truncate header and footer
	text = text.replace(chr(13) + ' ', chr(10))		# Convert TI89 line endings to Unix's
	text = text.replace(' ' + chr(12), chr(12))		# Truncate space before bookmarks
	text = translate(text, to89t=False)
	with open(path, 'wb') as txtfile:
		txtfile.write(text)
	return

#==============================================================================

colors = {'none': '\033[0m', 'bold_red': '\033[1;31m'}

def printerr(msg):
	print "%s!! %s%s" % (colors['bold_red'], msg, colors['none'])

def main():
	parser = OptionParser("usage: %prog [options] file")
	parser.add_option("-f", "--ti89file", action="store", type="string", dest="ti89file", help="The filename on the calc")
	parser.add_option("-d", "--ti89dir", action="store", type="string", dest="ti89dir", help="The directory on the calc")
	parser.add_option("-o", "--output", action="store", type="string", dest="txtfile", help="The .txt output filename on disk")
	(options, args) = parser.parse_args()
	
	if len(args) > 0:
		f = args[0]
	else:
		printerr("Source file missing")
		return 1
	
	try:
		with open(f) as thefile:
			filecontent = thefile.read()
	except:
		printerr("Error opening the file")
		return 1
	
	if f[-4:] != '.89t':
		# Convertire il file testo in .89t
		if options.ti89file != None and options.ti89dir != None:
			destfile = options.ti89dir + "." + options.ti89file + ".89t"
			to89t(destfile, filecontent, options.ti89file, options.ti89dir)
		else:
			printerr("-d and/or -f options missing")
			return 1
	else:
		if options.txtfile != None:
			totxt(options.txtfile, filecontent)
		else:
			printerr("-o option missing")
			return 1
	
if __name__ == "__main__":
	sys.exit(main())
