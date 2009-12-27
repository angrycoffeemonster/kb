#!/bin/sh
# Nautilus scripts installer - by Venator85
# Put all your scripts into ./scripts/ folder.

echo "Installing scripts..."
rm -f ~/.gnome2/nautilus-scripts/*
cd ./scripts/
for i in $(ls)
do
	cp ./$i ~/.gnome2/nautilus-scripts/
	chmod a+x ~/.gnome2/nautilus-scripts/$i
	echo "  * Succesfully installed $i"
done
echo "Installation complete."
