#!/usr/bin/env python

"""
Scans the current working directory for episodes (*.avi) and clean their file names: episode numbers are rewritten as <season>x<episode>, spaces are replaced with '.' and filenames are cleaned from crew tags.

Example:
	The.Big.Bang.Theory.S01E01.Pilot.HDTV-XOR.avi
-- becomes --
	The.Big.Bang.Theory.1x01.Pilot.avi
"""

import re
import os
import sys

def format_list_as_table(thelist, sep = ' -> '):
	if len(thelist) > 0:
		import operator
		lengths = []
		
		fields = len(thelist[0])
		for i in range(fields):
			field_values = map(operator.itemgetter(i), thelist)
			lengths.append(len(max(field_values, key=len)))
		
		out = []
		for l in thelist:
			line = []
			for c in range(fields):
				line.append(l[c].ljust(lengths[c]))
			out.append(sep.join(line))
		
		return out
	else:
		return []

ep_re1 = re.compile("(s(\d{1,2})e(\d{1,2}))", re.I)  		# s01e02
ep_re2 = re.compile("\D((\d{1,2})x(\d{1,2}))\D", re.I)		# 1x02
ep_re3 = re.compile("\D((\d{1,2})\.(\d{1,2}))\D", re.I)		# 1.02
ep_re4 = re.compile("\D((\d)(\d{2}))\D", re.I)				# 102
ep_re5 = re.compile("\D((\d{2})(\d{2}))\D", re.I)			# 0102

avi_re = re.compile("\.avi$", re.I)

clean_re = re.compile("(\.HDTV.*?)\.(?:avi|srt)$", re.I)	# removes HDTV.XviD-BiA and such

def getSeasonEpisode(f):
	episode = ep_re1.findall(f)
	if episode == []:
		episode = ep_re2.findall(f)
		if episode == []:
			episode = ep_re3.findall(f)	
			if episode == []:
				episode = ep_re4.findall(f)
				if episode == []:
					episode = ep_re5.findall(f)
					if episode == []:
						print "Couldn't extract season/episode numbers from:"
						print f
						return None
	# returns (season number, episode number, season and episode number as expressed in the filename)
	return (int(episode[0][1]), int(episode[0][2]), episode[0][0])

def formatSeasonEpisode(f):
	(seas, epis_, seas_epis) = getSeasonEpisode(f)
	epis = str(epis_)
	new_seas_epis = "%dx%s" % (seas, epis.zfill(2))
	f = f.replace(seas_epis, new_seas_epis)
	f = f.replace(" ", ".")
	ext = f[-4:]
	f_clean = clean_re.sub('', f)
	if f == f_clean:
		return f
	else:
		return f_clean + ext

if len(sys.argv) == 1:
	path = os.getcwd()
else:
	path = sys.argv[1]
lines = os.listdir(path)
os.chdir(path)

ren = {}
for ff in lines:
	f = ff.strip()
	if not avi_re.search(f) is None:
		ren[f] = formatSeasonEpisode(f)

ren_l = ren.items()
ren_l = sorted(ren_l, key = lambda a: a[1]) # sort by renamed filename (2nd field)
ren_lf = format_list_as_table(ren_l)

for i in range(len(ren_l)):
	f = ren_l[i]
	oldname = f[0]
	newname = f[1]
	os.rename(oldname, newname)
	print ren_lf[i]