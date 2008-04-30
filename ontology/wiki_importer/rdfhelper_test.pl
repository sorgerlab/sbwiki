use strict;
use RDF::Helper;


defined $ARGV[0] or die "error: no .owl file given\n";


my $rdf = RDF::Helper->new(
  BaseInterface => 'RDF::Core',
  ExpandQNames => 1,
  Namespaces => {
    rdf  => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs => 'http://www.w3.org/2000/01/rdf-schema#',
    owl  => 'http://www.w3.org/2002/07/owl#',
  },
);
$rdf->include_rdfxml(filename => $ARGV[0]);

# query the rdf itself for the base uri of the ontology
my $ontology_stmt = ($rdf->get_statements(undef, 'rdf:type', 'owl:Ontology'))[0];
$ontology_stmt or die "error: no owl:Ontology declared in input file\n";
# XXX: Is the following safe?  Might also be "/"... Does Protege always use "#"?
my $ontology_ns = $ontology_stmt->subject->as_string . "#";
# stick the ontology's namespace under a fixed name for convenience
# XXX: we need the uri for later, but to we need to stick it in $rdf?
$rdf->ns('_onto', $ontology_ns);


$DB::single = 1;


print "CLASSES\n=======\n";
my @class_stmts = $rdf->get_statements(undef, 'rdf:type', 'owl:Class');
foreach my $s (@class_stmts)
{
  print $s->subject->as_string, "\n";
}


1;
