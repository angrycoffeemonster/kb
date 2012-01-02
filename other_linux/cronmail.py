#!/usr/bin/env python

import sys
import re
import argparse

parser = argparse.ArgumentParser(description='Rewrites cron emails to be sent via a traditional SMTP server.')

parser.add_argument('--from', dest='from_email', required=True, help='The email address to be used in the From field (e.g. \'foo@bar.com\')')
parser.add_argument('--to', dest='to_email', required=True, help='The recipient of the email to be used in the To field (e.g. \'John <baz@baz.com>\')')
args = parser.parse_args()

f = sys.stdin
msg = f.read()

r = re.compile("Subject:.*?<(.*?)>", re.I)
newfrom = "From: Cron %s <%s>" % (r.findall(msg)[0], args.from_email)
newto = "To: %s" % (args.to_email)

rowstoreplace = 2
msglines = msg.split('\n')
for i in range(len(msglines)):
	l = msglines[i]
	if l.startswith("From:"):
		msglines[i] = newfrom
		rowstoreplace -= 1
	elif l.startswith("To:"):
		msglines[i] = newto
		rowstoreplace -= 1
	if rowstoreplace == 0:
		break

print("\n".join(msglines))
