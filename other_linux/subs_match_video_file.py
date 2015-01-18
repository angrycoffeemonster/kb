#!/usr/bin/env python

"""
Scans the current working directory or a directory passed on the command line for episodes (*.avi, *.mkv) and subtitles (*.srt) and renames subtitle filenames to match the corresponding episodes.
Episode numbers are always rewritten as <season>x<episode>, spaces are always replaced with '.' and filenames are always cleaned from crew tags.

Warning:	This program assumes that that, for each tuple: (season, episode), a single video file and a single subtitle file with those values exist in the current directory.
			** Practically, this requires a single TV series per directory. **

Examples:
	Fringe.S04E03.720p.HDTV.X264-DIMENSION.mkv -> Fringe.4x03.mkv
	fringe - 403 - subs.srt                    -> Fringe.4x03.srt
	
	The.Big.Bang.Theory.S01E01.Pilot.HDTV-XOR.avi -> The.Big.Bang.Theory.1x01.Pilot.avi
	Tbbt - 1x01 - Pilot.itasa.srt                 -> The.Big.Bang.Theory.1x01.Pilot.srt
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

ep_re = []
ep_re.append(re.compile("(s(\d{1,2})e(\d{1,2}))", re.I))  		# s01e02
ep_re.append(re.compile("\D((\d{1,2})x(\d{1,2}))\D", re.I))		# 1x02
ep_re.append(re.compile("\D((\d{1,2})\.(\d{1,2}))\D", re.I))	# 1.02
ep_re.append(re.compile("\D((\d)(\d{2}))\D", re.I))				# 102
ep_re.append(re.compile("\D((\d{2})(\d{2}))\D", re.I))			# 0102

video_re = re.compile("\.(?:avi|mkv|mp4|3gp)$", re.I)
sub_re = re.compile("\.srt$", re.I)

clean_re = re.compile("(\.(?:HDTV|720p).*?)\.(?:avi|mkv|mp4|3gp|srt)$", re.I)	# removes "HDTV.XviD-BiA", "720p.HDTV.X264-DIMENSION" and such

def getSeasonEpisode(f):
	matched = False
	episode = None
	for ep_re_ in ep_re:
		episode = ep_re_.findall(f)
		if episode != []:
			matched = True
			break
	
	if matched == False:
		raise UserWarning("Couldn't extract season/episode numbers from: %s" % (f))
	
	# returns (season number, episode number, season and episode number as expressed in the filename)
	return (int(episode[0][1]), int(episode[0][2]), episode[0][0])

def formatSeasonEpisode(f):
	(seas, epis_, seas_epis) = getSeasonEpisode(f)
	epis = str(epis_).zfill(2)
	new_seas_epis = "%dx%s" % (seas, epis)
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

videos = []
subs = []
for ff in lines:
	f = ff.strip()
	if not video_re.search(f) is None:
		videos.append(f)
	elif not sub_re.search(f) is None:
		subs.append(f)

ren = {}
for video in videos:
	try:
		(video_seas_no, video_epis_no, _) = getSeasonEpisode(video)
		for sub in subs:
			(sub_seas_no, sub_epis_no, _) = getSeasonEpisode(sub)
			if video_seas_no == sub_seas_no and video_epis_no == sub_epis_no:
				video_f = formatSeasonEpisode(video)
				ren[video] = video_f
				ren[sub] = video_f[:-3] + 'srt'
				break
	except UserWarning as w:
		print(w)

ren_l = ren.items()
ren_l = sorted(ren_l, key = lambda a: a[1]) # sort by renamed filename (2nd field)
ren_lf = format_list_as_table(ren_l)

for i in range(len(ren_l)):
	f = ren_l[i]
	oldname = f[0]
	newname = f[1]
	os.rename(oldname, newname)
	print ren_lf[i]
