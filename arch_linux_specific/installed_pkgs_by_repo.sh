#!/bin/bash

pacman -Qq `pacman -Sql $1` 2>/dev/null
