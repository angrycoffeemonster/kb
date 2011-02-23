#!/usr/bin/python
# coding: utf-8
#
# youtube2mp3.py
# by Alessio Bianchi <venator85@gmail.com>
#
# Requires youtube-dl (http://rg3.github.com/youtube-dl/) and ffmpeg
#

import sys
import subprocess

colors = {'none': '\033[0m',
	'black': '\033[0;30m',		'bold_black': '\033[1;30m',
	'red': '\033[0;31m',		'bold_red': '\033[1;31m',
	'green': '\033[0;32m',		'bold_green': '\033[1;32m',
	'yellow': '\033[0;33m',		'bold_yellow': '\033[1;33m',
	'blue': '\033[0;34m',		'bold_blue': '\033[1;34m',
	'magenta': '\033[0;35m',	'bold_magenta': '\033[1;35m',
	'cyan': '\033[0;36m',		'bold_cyan': '\033[1;36m',
	'white': '\033[0;37m',		'bold_white': '\033[1;37m'}

def printmsg(msg):
	print "%s>> %s%s" % (colors['bold_blue'], msg, colors['none'])

def printerr(msg):
	print "%s!! %s%s" % (colors['bold_red'], msg, colors['none'])

def printwarn(msg):
	print "%s!! %s%s" % (colors['bold_yellow'], msg, colors['none'])

# Run a command synchronously, redirecting stdout and stderr to strings
def runcmd(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(stdout, stderr) = pipe.communicate()	# wait for process to terminate and return stdout and stderr
	return {'stdout': stdout.strip(), 'stderr': stderr.strip(), 'retcode': pipe.returncode}

# Run a command synchronously, sending stdout and stderr to shell
def runcmd2(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=None, stderr=None)
	pipe.communicate()	# wait for process to terminate
	return pipe.returncode

def main(argv):
	if len(argv) != 2:
		printerr("Usage: youtube2mp3.py URL")
		return 1
	
	url = argv[1]
	printmsg("Downloading video...")
	
	videoname = runcmd("youtube-dl -e %s" % (url))['stdout'];
	videoname = videoname.replace(" ", "_")
	videoname = videoname.replace("/", "_")
	
	runcmd2("youtube-dl -o %s %s" % (videoname, url))
	audioname = videoname + ".mp3"
	
	printmsg("Extracting audio...")
	runcmd2("ffmpeg -i %s -ab 192000 -ar 44100 %s" % (videoname, audioname))
	
	printmsg("Done! Audio extracted to %s" % (audioname))
	return 0
	
if __name__ == '__main__':
	sys.exit(main(sys.argv))
