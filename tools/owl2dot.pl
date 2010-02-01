#!/usr/bin/perl

use strict;
use Getopt::Long;
use RDF::Helper;
use RDF::Helper::Constants qw(:rdf :rdfs);


my @skip_classes;
my $skip_reflexive = undef;

GetOptions(
  "skip-class|sc=s" => \@skip_classes,
  "skip-reflexive|sr" => \$skip_reflexive,
) or die "GetOptions error";


my ($owl_filespec, @owl_extra_filespecs) = @ARGV;
defined $owl_filespec  or die "error: no OWL filespec given\n";


my @owl_filespec_data = map { parse_owl_filespec($_) } $owl_filespec, @owl_extra_filespecs;
my %extra_ns = map { $_->{prefix} => $_->{uri}.$_->{separator} } @owl_filespec_data;

my $rdf = RDF::Helper->new(
  BaseInterface => 'RDF::Core',
  ExpandQNames => 1,
  Namespaces => {
    rdf  => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs => 'http://www.w3.org/2000/01/rdf-schema#',
    xsd  => 'http://www.w3.org/2001/XMLSchema#',
    owl  => 'http://www.w3.org/2002/07/owl#',
    %extra_ns,
  },
);
foreach my $filename ( map($_->{filename}, @owl_filespec_data) )
{
  $rdf->include_rdfxml(filename => $filename);
}

foreach my $uri ( map($_->object->as_string,
                      $rdf->get_statements(undef, 'owl:imports', undef)) )
{
  if ( ! grep($_->{uri} eq $uri, @owl_filespec_data) )
  {
    die "OWL file specification not provided for imported ontology: $uri\n";
  }
}


my %skip_classes = map { $_ => undef } @skip_classes;


print "digraph g {\n";


my %uri_to_id;


# classes
foreach my $uri ( $rdf->resourcelist(RDF_TYPE, 'owl:Class') )
{
  next if $uri =~ /^_/;
  next if exists $skip_classes{$uri};

  my $obj = $rdf->get_object($uri);

  my $id = $uri;
  $id =~ s|^\w+://.*?#||;
  $id =~ tr/-/_/;
  $uri_to_id{$uri} = $id;

  my $label = $obj->rdfs_label;
  $label = join(' ', map(ucfirst, split(' ', $label)));

  print qq{$id [label="$label"]\n};
}


# sub/superclass links
foreach my $uri ( $rdf->resourcelist(RDFS_SUBCLASS_OF) )
{
  my $super_uri = $rdf->get_object($uri)->rdfs_subClassOf->object_uri;

  next if exists $skip_classes{$uri} or exists $skip_classes{$super_uri};

  print qq{$uri_to_id{$super_uri} -> $uri_to_id{$uri} [color="#ff0000" dir=back] \n};
}


# range/domain links
foreach my $uri ( $rdf->resourcelist(RDF_TYPE, 'owl:ObjectProperty') )
{
  my $obj = $rdf->get_object($uri);

  next unless $obj->rdfs_domain and $obj->rdfs_range;

  my @domains = ($obj->rdfs_domain);
  if ( my $union = $domains[0]->owl_unionOf )
  {
    @domains = parse_list($rdf, $union);
  }
  my $range = $obj->rdfs_range; # TODO: support multiple classes for range

  my $range_uri = $range->object_uri;
  my $label = $obj->rdfs_label;

  next if exists $skip_classes{$range_uri};

  foreach my $domain ( @domains )
  {
    my $domain_uri = $domain->object_uri;
    next if exists $skip_classes{$domain_uri};
    if ($domain_uri eq $range_uri and $skip_reflexive)
    {
      print STDERR "skipping reflexive property: ", $domain->rdfs_label, " -- ", $obj->rdfs_label, "\n";
      next;
    }
    print qq{$uri_to_id{$domain_uri} -> $uri_to_id{$range_uri} [label="$label"] \n};
  }
}


print "}\n";


#$DB::single=1;
#print_statement(($rdf->get_statements(undef, 'http://pipeline.med.harvard.edu/ssw-20090421.owl#isVirtual', undef))[0]);


1;




sub parse_owl_filespec
{
  my ($filespec) = @_;

  my @parts = split(/:/, $filespec, 3);
  if ( @parts != 3 )
  {
    die "OWL file specification must be in the form filename:prefix:uri (got: $filespec)\n";
  }

  my %ret;
  @ret{qw(filename prefix uri)} = @parts;
  $ret{separator} = substr($ret{uri}, -1, 1, '');

  return \%ret;
}



# rdf : RDF::Helper
# obj : RDF::Helper::Object
# returns a list of ::Objects
sub parse_list
{
  my ($rdf, $obj) = @_;

  my @values;
  do
  {
    push @values, $obj->rdf_first;
    $obj = $obj->rdf_rest;
  } until ( $obj eq RDF_NIL ); # RDF::Helper::Object only overloads 'eq'

  return @values;
}

