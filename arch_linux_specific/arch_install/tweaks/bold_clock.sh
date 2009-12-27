#!/bin/bash

gconftool-2 -s -t string /apps/panel/applets/clock_screen0/prefs/format custom
gconftool-2 -s -t string /apps/panel/applets/clock_screen0/prefs/custom_format "%a %d, <b>%H:%M:%S</b>"
