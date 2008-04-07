#!/bin/sh

grep '^% ' | perl -pe 's/% //; s/ \+ /\n/g; s/ <?--> /\n/g' | perl -pe 's/ +$//' | perl -ne '$a{$_} or $a{$_}=1,print $_'
