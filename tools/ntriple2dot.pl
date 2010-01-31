#!/usr/bin/perl

# Turn an ntriple file (simple representation of rdf) into a .dot file
# for rendering with graphviz.

use strict;

my %classes;
my %nodes;

print "digraph g {\n";

while (<>)
{
  # parse ntriple line
  next unless my (@t) = /<(.*?)>\s*<(.*?)>\s*<(.*?)>/;

  # keep a list of classes we've seen
  $classes{$t[0]} = 1 if $t[2] eq 'http://www.w3.org/2002/07/owl#Class';

  # skip a bunch of properties we don't care about
  next if $t[1] eq 'http://semantic-mediawiki.org/swivt/1.0#page' or
    $t[1] eq 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy' or
    $t[1] eq 'http://www.w3.org/2002/07/owl#imports' or
    $t[1] eq 'http://www.w3.org/2002/07/owl#disjointWith' or
    $t[0] eq 'http://semantic-mediawiki.org/swivt/1.0#Subject' or
    $t[2] eq 'http://semantic-mediawiki.org/swivt/1.0#Subject' or
    $t[2] eq 'http://www.w3.org/2002/07/owl#Class' or
    $t[2] eq 'http://www.w3.org/2002/07/owl#ObjectProperty' or
    $t[2] eq 'http://www.w3.org/2002/07/owl#DatatypeProperty' or
    $t[2] eq 'http://www.w3.org/2002/07/owl#AnnotationProperty' or
    $t[2] =~ m|^http://www.w3.org/2001/XMLSchema#| or
    $t[0] eq 'file:/tmp/tmpb7UiTo-rdfconverter';

  # skip relations to classes (may or may not want this enabled)
  next if $t[1] eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' or
    $t[1] eq 'http://www.w3.org/2000/01/rdf-schema#subClassOf';

  foreach (@t)
  {
    # clean up uris to just the short name (possibly not unique but good enough for this)
    s|^\w+://||;
    s|dev.pipeline.med.harvard.edu/wiki/index.php/Special:URIResolver/||;
    s|pipeline.med.harvard.edu/sbwiki-20080408.owl#||;
    s|pipeline.med.harvard.edu/sb-20080408.owl#||;
    s|pipeline.med.harvard.edu/ssw-20090421.owl#||;
    # undo some uri escaping and such
    s|-2D|-|g;
    s|-|_|g;
  }

  # keep a list of all nodes we've seen
  $nodes{$t[0]} = 1;
  $nodes{$t[2]} = 1;

  my %edge_opts;

  # turn edge name into a nice label
  $edge_opts{label} = $t[1];
  $edge_opts{label} =~ s/.*#//;
  $edge_opts{label} =~ tr/_/ /;

  if ($t[1] eq 'www.w3.org/2000/01/rdf_schema#range')
  {
    $edge_opts{dir} = 'forward';
  }

  # print edge statement
  print "$t[0] -> $t[2]" .
    " [ " . join(', ', map("$_=\"$edge_opts{$_}\"", keys %edge_opts)) . " ]" .
    "\n";
}

foreach my $node (keys %nodes)
{
  # turn uid into a nice label
  (my $label = $node) =~ s/([A-Z]{2})_([A-Z]+)_(\d+)_(.*)/$1-$2-$3\\n$4/;
  $label =~ tr/_/ /;
  # print node statement
  print "$node [label=\"$label\"]\n";
}

print "}\n";

