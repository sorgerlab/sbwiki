#!/bin/bash

cd `dirname $0`
perl wiki_importer/ontology_loader_bot.pl \
  --wiki-username=ontologybot \
  $* \
  sb.owl:sb:http://pipeline.med.harvard.edu/sb-20100803.owl\# \
  sbwiki.owl:sbwiki:http://pipeline.med.harvard.edu/sbwiki-20100803.owl\# \
  ssw.owl:ssw:http://pipeline.med.harvard.edu/ssw-20090421.owl\# \
  > sbwiki_mediawiki_import.xml
