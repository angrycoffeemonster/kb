#!/usr/bin/env python

import sys
import os
import re
import os.path
import subprocess
import shutil
from optparse import OptionParser

colors = {'none': '\033[0m',
	'black': '\033[0;30m',
	'red': '\033[0;31m',
	'green': '\033[0;32m',
	'yellow': '\033[0;33m',
	'blue': '\033[0;34m',
	'magenta': '\033[0;35m',
	'cyan': '\033[0;36m',
	'white': '\033[0;37m',
	'bold_black': '\033[1;30m',
	'bold_red': '\033[1;31m',
	'bold_green': '\033[1;32m',
	'bold_yellow': '\033[1;33m',
	'bold_blue': '\033[1;34m',
	'bold_magenta': '\033[1;35m',
	'bold_cyan': '\033[1;36m',
	'bold_white': '\033[1;37m'}

def printmsg(msg):
	print "%s>> %s%s" % (colors['bold_magenta'], msg, colors['none'])

def printerr(msg):
	print "%s!! %s%s" % (colors['bold_red'], msg, colors['none'])

# Run a command synchronously, redirecting stdout and stderr to strings
def runcmd(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(stdout, stderr) = pipe.communicate()	# wait for process to terminate and return stdout and stderr
	return {'stdout': stdout.strip(), 'stderr': stderr.strip(), 'retcode': pipe.returncode}

# Run a command synchronously, without redirecting stdout and stderr
def runcmd2(cmd, cwd=None):
	pipe = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=None, stderr=None)
	pipe.communicate()	# wait for process to terminate
	return {'retcode': pipe.returncode}

def main():
	parser = OptionParser()
	parser.add_option("-r", "--remove", action="append", dest="removepkgnames", type="string", metavar="PKGTOREMOVE", help="removes a package by name")
	(options, args) = parser.parse_args()
	
	conf_file = os.path.join(os.path.abspath(os.path.dirname(sys.argv[0])), 'repo-sync.conf')
	if os.path.isfile(conf_file):
		config = eval(open(conf_file).read())
	else:
		printerr("Config file " + conf_file + " not found")
		return

	repofile = config['repo_name'] + '.db.tar.gz'
	remote_repo_path = config['remote_username'] + "@" + config['remote_host'] + ":" + config['remote_directory']
	
	if runcmd("which repo-clean")['retcode'] != 0:
		printerr("Warning: repo-clean is not available, outdated packages will not be removed!")
		printerr("Please install repo-clean from the AUR")
	
	### upload and refresh packages #############
	for pkg in args:
		if os.path.isfile(pkg):
			printmsg("Moving new package " + pkg + " to local repo")
			shutil.move(pkg, config['local_directory'])
			
			printmsg("Adding " + pkg + " to the repository db")
			r_add=runcmd2("repo-add " + repofile + " " + pkg, config['local_directory'])
			retcode = r_add['retcode']
			if retcode != 0:
				printerr("Error adding " + pkg + " to the repository db")
				continue
			
			print ""
		else:
			printerr("Local package " + pkg + " doesn't exist")
	#############################################
	
	### remove package by name ##################
	if options.removepkgnames != None:
		for pkg in options.removepkgnames:
			printmsg("Removing " + pkg + " from the repository db")
			retcode = runcmd2("repo-remove " + repofile + " " + pkg, config['local_directory'])['retcode']
			if retcode != 0:
				printerr("Error removing " + pkg + " from the repository db")
				continue
			
			try:
				# remove older versions of the package
				pkg_to_delete = re.compile(pkg + ".*\.pkg\.tar\.gz")
				
				repo_files = runcmd('ls -1 *.pkg.tar.gz', config['local_directory'])['stdout'].split()
				for filename in repo_files:
					if pkg_to_delete.match(filename):
						printmsg("Deleting " + filename + " from repo")
						os.remove(config['local_directory'] + filename)
			except Exception:
				printerr("Error deleting " + pkg)
				continue
	#############################################

	# Remove outdated packages with repo-clean (http://code.google.com/p/repo-clean/)
	if runcmd2("repo-clean -m c -s .", config['local_directory'])['retcode'] != 0:
		printerr("Error removing outdated packages")

	# Remove original db file
	os.remove(config['local_directory'] + repofile + '.old')

	# Rsync remote repository
	printmsg("Rsyncing remote repository")
	
	rsync_cmd = "rsync -avL --delete --progress . " + remote_repo_path
	ret = runcmd2(rsync_cmd, config['local_directory'])
	if ret['retcode'] != 0:
		printerr("Error rsyncing remote repository (code " + ret['retcode'] + ")")
		return	
	
	#############################################

if __name__ == "__main__":
	main()
