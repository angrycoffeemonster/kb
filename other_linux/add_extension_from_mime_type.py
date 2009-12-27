#!/usr/bin/env python
"""It is a `filename -> filename.ext` filter. 

   `ext` is mime-based.

"""
import mimetypes
import os
import sys
from subprocess import Popen, PIPE

file2exts = {
	"python":	"py",
	"shell":	"sh",
	"ascii":	"txt",
	"utf-8":	"txt",
	"xml":	"xml",
	"php":	"php",
	"gzip":	"gz",
	"tar":	"tar"
}

files = sys.stdin.readlines()[0].split("\x00")
files = files[:-1]

for filename in files:
	output, _ = Popen(['file', '-b', filename], stdout=PIPE).communicate()
	mime = output.split(';', 1)[0].lower().strip()
	if mime.find("shell")>0:
		ext = None
		for t_ext in file2exts:
			if mime.find(t_ext) > 0:
				ext = file2exts[t_ext]
				break
		if not ext is None:
			newname = filename + '.' + ext
			print newname
			os.rename(filename, newname)