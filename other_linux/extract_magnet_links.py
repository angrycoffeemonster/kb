#!/usr/bin/env python2

"""
Extracts magnet links from .html files (tested with eztv.it)
"""

import re
import os
import sys
import urllib2

magnet_re = re.compile("href=\"(magnet:.+?)\"", re.I)

f = urllib2.urlopen(sys.argv[1])
lines = f.readlines()

for l in lines:
	mat = magnet_re.findall(l)
	if len(mat) > 0:
		print mat[0]
	
