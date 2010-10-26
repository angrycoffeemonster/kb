#!/usr/bin/env python

import os
import subprocess
import sys

# Run a command synchronously, sending stdout and stderr to shell
def runcmd2(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=None, stderr=None)
	pipe.communicate()      # wait for process to terminate
	return pipe.returncode

f = open(sys.argv[1], 'r')
lines = f.readlines()

for ll in lines:
	l = ll.strip()
	cmd = "transmission-remote -N /home/venator/.netrc -a \"%s\"" % (l)
	runcmd2(cmd)
