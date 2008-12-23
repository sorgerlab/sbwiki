use strict;
use RDF::Helper;
use RDF::Helper::Constants qw(:rdf :rdfs);


my $rdf = RDF::Helper->new(
  BaseInterface => 'RDF::Core',
  ExpandQNames => 1,
  Namespaces => {
    rdf  => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs => 'http://www.w3.org/2000/01/rdf-schema#',
    xsd  => 'http://www.w3.org/2001/XMLSchema#',
    owl  => 'http://www.w3.org/2002/07/owl#',
  },
);
$rdf->include_rdfxml(filename => '../sbwiki.owl');


my $prefix = 'sbwiki';


# query the rdf itself for the base uri of the ontology
my $ontology_stmt = ($rdf->get_statements(undef, RDF_TYPE, 'owl:Ontology'))[0];
$ontology_stmt or die "error: no owl:Ontology declared in input file";
# XXX: Is the following safe?  Might also be "/"... Does Protege always use "#"?
my $ontology_ns = $ontology_stmt->subject->as_string . "#";
# store the ontology's namespace so the convenience object functions work
$rdf->ns($prefix, $ontology_ns);
$rdf->{_NS}{$ontology_ns} = $prefix; # FIXME: patch RDF::Helper subclasses to do this


#####


my $uri = 'http://pipeline.med.harvard.edu/sbwiki-20080408.owl#Protein';
my $object = $rdf->get_object($uri);

my @a = ancestors($rdf, $object);



$DB::single=1;
1;


sub ancestors
{
  my ($rdf, @classes) = @_;

  # note that the body is appending to the array as we iterate!
  foreach my $class ( @classes )
  {
    push @classes, $class->rdfs_subClassOf unless !defined $class;
  }

  # remove undefs and duplicates
  my %seen;
  @classes = grep { defined $_ and !$seen{$_}++ } @classes;

  return @classes;
}
