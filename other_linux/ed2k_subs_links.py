#!/usr/bin/python

# takes ed2k links of video and subs and makes the subs links filenames to match the video filenames
# eg bla.avi, bla_sub.srt -> bla.avi, bla.srt

import os
import subprocess

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
links = links_text.strip().split("\n")

vids = []
subs = []
for l in links:
	ltokens = l.split("|")
	lfname = ltokens[2]
	if lfname.lower().endswith('srt'):
		subs.append(l)
	else:
		vids.append(l)

fin=""
for i in range(0,len(vids)):
	v = vids[i]
	fin+=v + "\n"
	vname = v.split("|")[2]
	try:
		s=subs[i]
		slist=s.split("|")
		slist[2] = vname[:-3] + "srt"
		fin+="|".join(slist) + "\n"
	except IndexError:
		pass

if osname == 'Darwin':
	p=subprocess.Popen("pbcopy", stdout=subprocess.PIPE, stdin=subprocess.PIPE)
	p.communicate(input=fin)
elif osname == 'Linux':
	clipboard.set_text(fin)
	clipboard.store()
