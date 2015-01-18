#!/usr/bin/env python

import os
import subprocess
import sys

def runcmd(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(stdout, stderr) = pipe.communicate()	# wait for process to terminate and return stdout and stderr
	return {'stdout': stdout.strip(), 'stderr': stderr.strip(), 'retcode': pipe.returncode}

# Run a command synchronously, sending stdout and stderr to shell
def runcmd2(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=None, stderr=None)
	pipe.communicate()      # wait for process to terminate
	return pipe.returncode

def add(l):
	cmd = "transmission-remote -N /home/venator/.transmission_daemon_rc -a \"%s\"" % (l)
	runcmd2(cmd)

def process_file_with_links(fname):
	f = open(fname, 'r')
	lines = f.readlines()
	for ll in lines:
		l = ll.strip()
		if l.find("magnet") != -1:
			add(l)

def is_torrent_file(fname):
	out = runcmd("file -b \"%s\"" % (fname))['stdout'].lower()
	out = str(out)
	if out.find("torrent") >= 0:
		return True
	else:
		return False

if len(sys.argv) == 1:
	print(":: Usage ")
else:
	args = sys.argv[1:]
	for i in args:
		print("processing [%s]" % (i))
		if is_torrent_file(i):
			add(i)
		else:
			process_file_with_links(i)
