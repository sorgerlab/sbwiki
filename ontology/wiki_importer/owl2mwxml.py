#!/usr/bin/python

import sys
from rdflib.Graph import Graph
from rdflib.Namespace import Namespace

if len(sys.argv) <= 1:
    print "ERROR: must specify an .owl file to parse";
    sys.exit(1);

RDF = Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#')
RDFS = Namespace('http://www.w3.org/2000/01/rdf-schema#')
XSD = Namespace('http://www.w3.org/2001/XMLSchema#')
OWL = Namespace('http://www.w3.org/2002/07/owl#')

graph = Graph()
graph.load(sys.argv[1])

# extract the ontology's namespace uri
onto_base = graph.value(predicate=RDF['type'], object=OWL['Ontology'], any=False)
# XXX: Is this safe?  Might also be "/"... Does Protege always use "#"?
ONTO = Namespace(onto_base + "#")

for s,p,o in graph.triples((None, RDF['type'], OWL['Class'])):
    if s.startswith(ONTO):
        label = graph.value(s, RDFS['label'], None, any=False)
        print label
