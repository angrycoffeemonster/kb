#!/bin/bash

du -sh .
find . -name "*.sqlite" -exec sqlite3 '{}' "VACUUM;" \;
du -sh .