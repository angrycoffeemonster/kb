#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Cleans video file names from garbage.
Reads a list of ed2k links of video files from the clipboard (Mac & Linux only)
Episodes number are always rewritten in all links as <season>x<episode>.

Example:
	ed2k://|file|The.Big.Bang.Theory.-.S01E01.-..Pilot.HDTV-XOR.avi|182818448|C6F20CDF706B64366ED9FF0ED56B4443|h=RX3XQZ6VC2UM6PRGQ26CUL7DIBJYRM6X|/
-- becames --
	ed2k://|file|The.Big.Bang.Theory.1x01.Pilot.avi|182818448|C6F20CDF706B64366ED9FF0ED56B4443|h=RX3XQZ6VC2UM6PRGQ26CUL7DIBJYRM6X|/
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

clean_re1 = re.compile("(\.HDTV.*?)$", re.I)	# removes HDTV.XviD-BiA and such
clean_re2 = re.compile("(\.dvd[^r]?rip.*?)$", re.I)	# removes dvdrip.ita-eng.g66 and such
clean_re3 = re.compile("(\.dvd[^m]?mux.*?)$", re.I)	# removes dvd.mux.ita-eng.g66 and such

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
#print links_text; print
lines = links_text.strip().split("\n")

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
						print  "Couldn't extract season/episode numbers from: %s" % (f)
						return None
	return (int(episode[0][1]), int(episode[0][2]), episode[0][0])

def formatSeasonEpisode(f):
	(seas, epis_, seas_epis) = getSeasonEpisode(f)
	epis = str(epis_)
	new_seas_epis = "%dx%s" % (seas, epis.zfill(2))
	return f.replace(seas_epis, new_seas_epis)

def formatName(f):
	f = urllib.unquote(f)
	f = f.replace(" ", ".")		#replace spaces with dots
	
	# replace .-. with .
	f = f.replace(".-.", ".")
	
	# replace " with '
	f = f.replace('"', "'")
	
	# replace accented vowels
	f = f.replace("à", "a'")
	f = f.replace("è", "e'")
	f = f.replace("é", "e'")
	f = f.replace("ì", "i'")
	f = f.replace("ò", "o'")
	f = f.replace("ù", "u'")
	
	# remove multiple dots
	while f.find("..") > 0:
		f = f.replace("..", ".")
	
	# remove tags from file
	extpos = f.rfind(".")
	ext = f[extpos:]	#save file extension
	f = f[:extpos]
	f = clean_re1.sub('', f)
	f = clean_re2.sub('', f)
	f = clean_re3.sub('', f)
	f = f + ext
	
	# format season and episode
	f = formatSeasonEpisode(f)
	
	return f	

out = []
for ff in lines:
	f = ff.strip()
	if f=="": continue
	f = f.replace("ed2k://|file|", "")
	name = f[0:f.find("|")]		#original name
	fhash = f[f.find("|"):]		#after the name (size, hash ecc)
	name = formatName(name)
	newlink = "ed2k://|file|" + name + fhash
	out.append(newlink)

fin = "\n".join(out)
#print fin

if osname == 'Darwin':
	p=subprocess.Popen("pbcopy", stdout=subprocess.PIPE, stdin=subprocess.PIPE)
	p.communicate(input=fin)
elif osname == 'Linux':
	clipboard.set_text(fin)
	clipboard.store()
