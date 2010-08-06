#!/bin/bash

dest_base='orchestra:/www/pipeline.med.harvard.edu/docroot/'

cd $(dirname $0)

for f in *.owl
do
  dest_suffix=$(grep xml:base $f | sed -e 's/ \+xml:base="http:\/\/[^/]\+\/\([^"]\+\).*/\1/')
  dest_path=${dest_base}${dest_suffix}
  echo $f '-->' $dest_path
  scp $f $dest_path
done
