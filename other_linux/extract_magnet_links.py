#!/usr/bin/env python

"""
Extracts magnet links from .html files (tested with eztv.it)
"""

import re
import os
import sys

magnet_re = re.compile("href=\"(magnet:.+?)\"", re.I)

f = open(sys.argv[1], 'r')
lines = f.readlines()

for l in lines:
	mat = magnet_re.findall(l)
	if len(mat) > 0:
		print mat[0]
	