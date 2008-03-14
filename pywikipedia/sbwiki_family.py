# -*- coding: utf-8  -*-
 
import family
 
# Systems Biology wiki
 
class Family(family.Family):
 
    def __init__(self):
        family.Family.__init__(self)
        self.name = 'sbwiki' #Set the family name; this should be the same as in the filename.
        self.langs = {
            'live': 'pipeline.med.harvard.edu', #Put the hostname here.
            'dev':  'dev.pipeline.med.harvard.edu', #Put the hostname here.
        }
        self.namespaces[4] = {
            '_default': u'SBWiki', #Specify the project namespace here. Other
        }                               #namespaces will be set to MediaWiki default.

        self.namespaces[5] = {
            '_default': u'SBWiki talk',
        }

    def version(self, code):
        return "1.12alpha"  #The MediaWiki version used. Not very important in most cases.

    def path(self, code):
        return '/wiki/index.php' #The path of index.php

    def protocol(self, code):
        return 'https' # force https urls
