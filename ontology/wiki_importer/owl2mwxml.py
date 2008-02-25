#!/usr/bin/python

import sys
from rdflib.Graph import Graph
from rdflib.Namespace import Namespace

if len(sys.argv) <= 1:
    print "ERROR: must specify an .owl file to parse";
    sys.exit(1);

graph = Graph()
graph.load(sys.argv[1])

RDF_NS = Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
OWL_NS = Namespace('http://www.w3.org/2002/07/owl#');

#print graph.serialize(format='turtle')

for s,p,o in graph.triples((None, RDF_NS['type'], OWL_NS['Class'])): 
    print s
