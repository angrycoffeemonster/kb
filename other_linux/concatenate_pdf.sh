#!/bin/bash

# concatena i file pdf nel file lista eliminando l'ultima pagina di ciascun file
# script scritto per concatenare i file del perl book

counter=0
FILES=""
RANGES=""
IDS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
for f in `cat lista`
do
	NUMPAGES=`pdftk $f dump_data output | grep Num | cut -d ' ' -f 2`
	let PENULTIMAPAG=NUMPAGES-1
	indice=${IDS:$counter:1}
	FILES="$FILES $indice=$f"
	RANGES="$RANGES ${indice}1-$PENULTIMAPAG"
	let counter=counter+1
done

pdftk $FILES cat $RANGES output perlbook.pdf
