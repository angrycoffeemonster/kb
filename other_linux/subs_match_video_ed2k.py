#!/usr/bin/env python

"""
Reads from the clipboard (Mac & Linux only) a list of ed2k links, one per line, of video (*.avi) and subtitle files(other extensions, e.g. for zipped subtitles) (no particular order required).
Rewrites the subtitle links to have the same filename as their corresponding video files and copies the result to the clipboard.
Episodes number are always rewritten in all links as <season>x<episode>.

Example:
	ed2k://|file|The.Big.Bang.Theory.S01E01.Pilot.HDTV-XOR.avi|182818448|C6F20CDF706B64366ED9FF0ED56B4443|h=RX3XQZ6VC2UM6PRGQ26CUL7DIBJYRM6X|/
	ed2k://|file|The%20Big%20Bang%20Theory%20-%201x01%20-%20Pilot.itasa.srt|33453|D37416911C3E2984770FEF883D5D6D93|h=R5E3BMHCHUJN3NJQXINTZOZ3YDIGXQ5A|/
-- becames --
	ed2k://|file|The.Big.Bang.Theory.1x01.Pilot.HDTV-XOR.avi|182818448|C6F20CDF706B64366ED9FF0ED56B4443|h=RX3XQZ6VC2UM6PRGQ26CUL7DIBJYRM6X|/
	ed2k://|file|The.Big.Bang.Theory.1x01.Pilot.HDTV-XOR.srt|33453|D37416911C3E2984770FEF883D5D6D93|h=R5E3BMHCHUJN3NJQXINTZOZ3YDIGXQ5A|/
"""

import re
import urllib
import os
import subprocess

ep_re1 = re.compile("(s(\d{1,2})e(\d{1,2}))", re.I)  		#s01e02
ep_re2 = re.compile("\D((\d{1,2})x(\d{1,2}))\D", re.I)		#1x02
ep_re3 = re.compile("\D((\d{1,2})\.(\d{1,2}))\D", re.I)		#1.02
ep_re4 = re.compile("\D((\d)(\d{2}))\D", re.I)				#102
ep_re5 = re.compile("\D((\d{2})(\d{2}))\D", re.I)			#0102

avi_re = re.compile("\.avi\|", re.I)
avi_re2 = re.compile("\.avi", re.I)

def runcmd(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(stdout, stderr) = pipe.communicate()	# wait for process to terminate and return stdout and stderr
	return {'stdout': stdout.strip(), 'stderr': stderr.strip(), 'retcode': pipe.returncode}

links_text = ""
osname = os.uname()[0]
if osname == 'Darwin':
	links_text = runcmd("pbpaste")['stdout']
elif osname == 'Linux':
	import pygtk, gtk, sys
	clipboard = gtk.clipboard_get()
	links_text = clipboard.wait_for_text()

if not links_text.startswith("ed2k://"):
	print >> sys.stderr, "!! No ed2k links found in the clipboard"
	sys.exit(1)
print links_text; print
lines = links_text.strip().split("\n")

def getSeasonEpisode(ff):
	f=ff.split("|")[2]
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
	return (int(episode[0][1]), int(episode[0][2]), episode[0][0])

def formatSeasonEpisode(f):
	(seas, epis_, seas_epis) = getSeasonEpisode(f)
	epis = str(epis_)
	new_seas_epis = "%dx%s" % (seas, epis.zfill(2))
	return f.replace(seas_epis, new_seas_epis)

avis = []
subs = []
for ff in lines:
	f = urllib.unquote(ff.strip())
	if not avi_re.search(f) is None:
		avis.append(f)
	else:
		subs.append(f)

out = []
for avi in avis:
	(avi_seas_no, avi_epis_no, _) = getSeasonEpisode(avi)
	for sub in subs:
		(sub_seas_no, sub_epis_no, _) = getSeasonEpisode(sub)
		if avi_seas_no == sub_seas_no and avi_epis_no == sub_epis_no:
			avi_f = formatSeasonEpisode(avi)
			out.append(avi_f)
			avi_title = avi_f.split("|")[2]
			s = sub.split("|")
			sub_ext = s[2].split('.')[-1]
			s[2] = avi_re2.sub("."+sub_ext, avi_title)
			out.append('|'.join(s))
			break		# comment this line to allow more than one sub file (with the same name!) per video file

fin = "\n".join(out)
print fin

if osname == 'Darwin':
	p=subprocess.Popen("pbcopy", stdout=subprocess.PIPE, stdin=subprocess.PIPE)
	p.communicate(input=fin)
elif osname == 'Linux':
	clipboard.set_text(fin)
	clipboard.store()
