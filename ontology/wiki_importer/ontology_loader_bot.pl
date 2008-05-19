#!/usr/bin/perl

# FIXME: need to create stuff in the right order, or force SMW refresh
#   (e.g. Property:Abbreviation before Categories, since they use Abbrevs)

use strict;
use Getopt::Long;
use RDF::Helper;
use RDF::Helper::Constants qw(:rdf);
use Perlwikipedia;


my $owl_filename   = splice(@ARGV, 0, 1);
my @wiki_opts      = splice(@ARGV, 0, 2);
my @wiki_login     = splice(@ARGV, 0, 2);

defined $owl_filename  or die "error: no .owl file given";
defined $wiki_opts[1]  or die "error: must provide wiki url and script path";
defined $wiki_login[1] or die "error: must provide wiki username and password";

my ($skip_import, $skip_category, $skip_object, $skip_datatype);

GetOptions(
  "skip-import|si"   => \$skip_import,
  "skip-category|sc" => \$skip_category,
  "skip-object|so"   => \$skip_object,
  "skip-datatype|sd" => \$skip_datatype,
  "dry-run|n"        => sub {$skip_import=$skip_category=$skip_object=$skip_datatype=1},
) or die "";


$wiki_login[0] = ucfirst($wiki_login[0]); # force this to make bot module happy
my $wiki = Perlwikipedia->new;
$wiki->set_wiki(@wiki_opts);
$wiki->login(@wiki_login) == 0
  or die "error: could not log into wiki:\n", $wiki->{errstr};


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
$rdf->include_rdfxml(filename => $owl_filename);

my %xsd_smw_types = (
  string  => 'String',
  int     => 'Number',
  float   => 'Number',
  boolean => 'Boolean',
  date    => 'Date',
);

my $prefix = 'sbwiki';


# query the rdf itself for the base uri of the ontology
my $ontology_stmt = ($rdf->get_statements(undef, RDF_TYPE, 'owl:Ontology'))[0];
$ontology_stmt or die "error: no owl:Ontology declared in input file";
# XXX: Is the following safe?  Might also be "/"... Does Protege always use "#"?
my $ontology_ns = $ontology_stmt->subject->as_string . "#";
# store the ontology's namespace so the convenience object functions work
$rdf->ns($prefix, $ontology_ns);
$rdf->{_NS}{$ontology_ns} = $prefix; # FIXME: patch RDF::Helper subclasses to do this


my $edit_summary = "OWL import from '$owl_filename'";

my $import_text  = "$ontology_ns|[$ontology_ns $prefix]\n";
my $import_title = 'MediaWiki:Smw_import_' . $prefix;


# translate owl:Class to SMW Category
foreach my $uri ( map($_->subject->as_string,
                      $rdf->get_statements(undef, RDF_TYPE, 'owl:Class')) )
{
  my $obj = $rdf->get_object($uri);
  my $id = uri_split($uri, $ontology_ns) or next;

  my $label = $obj->rdfs_label;
  if (!$label)
  {
    die "error: no rdfs:label given for '$uri'\n";
  }

  print "category: $label\n";
  my $page_text = "This category represents [[imported from::$prefix:$id]].";

  if ($obj->rdfs_subClassOf)
  {
    my $superclass = $obj->rdfs_subClassOf->rdfs_label;
    print "  superclass: $superclass\n";
    $page_text .= " It is a subclass of [[:Category:$superclass|$superclass]].";
    $page_text .= " [[Category:$superclass]] ";
  }

  my $abbrev = $obj->sbwiki_abbreviation;
  if ($abbrev)
  {
    print "  abbreviation: $abbrev\n";
    $page_text .= " Its abbreviation is [[abbreviation::$abbrev|$abbrev]].";
  }

  $page_text .= " [[has default form::Form:$label| ]]\n\n";
  $page_text .= "[[Image:Ontobrowser.gif]] [{{fullurl:Special:OntologyBrowser|entitytitle={{PAGENAMEE}}&ns={{NAMESPACEE}}}} Open '''$label''' in the OntologyBrowser]\n\n";
  $page_text .= "[[Image:Add.png]] [{{fullurl:Special:AddDataUID|type_code={{urlencode:$abbrev}}&form={{urlencode:$label}}&lock_core_fields=1}} Create a new '''$label''']\n\n";

  # create category
  unless ($skip_category)
  {
    $wiki->edit("Category:$label", $page_text, $edit_summary);
  }

  $import_text .= " $id|Category\n";
}

print "\n";


# translate owl:ObjectProperty to SMW Property, with Type:Page
my @object_property_uris =
  map($_->subject->as_string,
      $rdf->get_statements(undef, RDF_TYPE, 'owl:ObjectProperty'));
foreach my $uri ( @object_property_uris )
{
  my $obj = $rdf->get_object($uri);
  my $id = uri_split($uri, $ontology_ns) or next;

  my $label = $obj->rdfs_label;
  if (!$label)
  {
    warn "warning: no rdfs:label given for '$uri', assuming '$id'";
    $label = $id;
  }

  my @domain_labels;
  my @domains = ($obj->rdfs_domain);
  if ( $domains[0] )
  {
    if ( my $union = $domains[0]->owl_unionOf )
    {
      @domains = parse_list($rdf, $union);
    }
    @domain_labels = map($_->rdfs_label, @domains);
  }

  my $range_label  = $obj->rdfs_range->rdfs_label;

  print "object property: $label\n";
  my $page_text = "This property represents [[imported from::$prefix:$id]].";
  if (@domain_labels)
  {
    print "  domain: @domain_labels\n";
    $page_text .= " Its domain is ";
    if (@domain_labels > 1)
    {
      foreach my $label (@domain_labels[0..$#domain_labels-1])
      {
        $page_text .= "[[has_domain_hint::Category:$label|$label]], ";
      }
      $page_text =~ s/, $/ /; # strip final comma (looks better when N=2, also ok when N>2)
      $page_text .= "and ";
    }
    my $last_label = $domain_labels[$#domain_labels];
    $page_text .= "[[has_domain_hint::Category:$last_label|$last_label]].";
  }
  if ($range_label)
  {
    print "  range: $range_label\n";
    $page_text .= " Its range is [[has_range_hint::Category:$range_label|$range_label]].";
  }

  # create property
  unless ($skip_object)
  {
    $wiki->edit("Property:$label", $page_text, $edit_summary);
  }

  $import_text .= " $id|Type:Page\n";
}

print "\n";


# translate owl:DatatypeProperty to SMW Property, with Type based on the XSD type
my @datatype_property_uris =
  map($_->subject->as_string,
      $rdf->get_statements(undef, RDF_TYPE, 'owl:DatatypeProperty'));
foreach my $uri ( @datatype_property_uris )
{
  my $obj = $rdf->get_object($uri);
  my $id = uri_split($uri, $ontology_ns) or next;

  my $xsd_type = uri_split($obj->rdfs_range, $rdf->ns('xsd')) or
    die("error: unknown namespace for rdfs:range '", $obj->rdfs_range,
        "' on datatype property '$uri'");
  my $smw_type = $xsd_smw_types{$xsd_type} or
    die "error: unknown XML Schema data type '$xsd_type' on datatype property '$uri'\n";

  my $label = $obj->rdfs_label;
  if (!$label)
  {
    warn "warning: no rdfs:label given for '$uri', assuming '$id'";
    $label = $id;
  }

  my @domain_labels;
  my @domains = ($obj->rdfs_domain);
  if ( $domains[0] )
  {
    if ( my $union = $domains[0]->owl_unionOf )
    {
      @domains = parse_list($rdf, $union);
    }
    @domain_labels = map($_->rdfs_label, @domains);
  }

  print "datatype property: $label\n";
  my $page_text = "This property represents [[imported from::$prefix:$id]].";
  if (@domain_labels)
  {
    print "  domain: @domain_labels\n";
    $page_text .= " Its domain is ";
    if (@domain_labels > 1)
    {
      foreach my $label (@domain_labels[0..$#domain_labels-1])
      {
        $page_text .= "[[has_domain_hint::Category:$label|$label]], ";
      }
      $page_text =~ s/, $/ /; # strip final comma (looks better when N=2, also ok when N>2)
      $page_text .= "and ";
    }
    my $last_label = $domain_labels[$#domain_labels];
    $page_text .= "[[has_domain_hint::Category:$last_label|$last_label]].";
  }

  print "  range: $smw_type\n";
  $page_text .= " Its range is literal [[Type:$smw_type|$smw_type]] values.";

  # create property
  unless ($skip_datatype)
  {
    $wiki->edit("Property:$label", $page_text, $edit_summary);
  }

  $import_text .= " $id|Type:$smw_type\n";
}

print "\n";


print "final SMW import\n";
# create "magic" import page
unless ($skip_import)
{
  $wiki->edit($import_title, $import_text, $edit_summary);
}



# ============================================================



sub uri_split
{
  my ($uri, $ns) = @_;

  $uri =~ /^\Q$ns\E(.*)/;

  return $1;
}



# rdf : RDF::Helper
# obj : RDF::Helper::Object
# returns a list of ::Object
sub parse_list
{
  my ($rdf, $obj) = @_;

  my @values;
  do
  {
    push @values, $obj->rdf_first;
    $obj = $obj->rdf_rest;
  } until ($obj eq RDF_NIL); # RDF::Helper::Object only overloads 'eq'

  return @values;
}
