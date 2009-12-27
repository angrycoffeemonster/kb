#!/bin/bash

#fix firefox segmentation fault due to nvidia+silverlight/flash

LD_PRELOAD=/usr/lib/libGL.so.1 firefox $@
