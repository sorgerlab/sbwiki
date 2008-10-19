#!/usr/bin/perl

# FIXME: need to create stuff in the right order, or force SMW refresh
#   (e.g. Property:Abbreviation before Categories, since they use Abbrevs)

use strict;
use Getopt::Long;
use RDF::Helper;
use RDF::Helper::Constants qw(:rdf :rdfs);
use Perlwikipedia;


my $owl_filename   = splice(@ARGV, 0, 1);
my @wiki_opts      = splice(@ARGV, 0, 2);
my @wiki_login     = splice(@ARGV, 0, 2);

defined $owl_filename  or die "error: no .owl file given";
defined $wiki_opts[1]  or die "error: must provide wiki url and script path";
defined $wiki_login[1] or die "error: must provide wiki username and password";

my ($skip_import, $skip_category, $skip_object, $skip_datatype, $skip_template, $skip_form);

# NB: add new skip_* parameters to the dry-run line at the bottom
#   (could probably do this programatically if I read up on Getopt)
GetOptions(
  "skip-import|si"   => \$skip_import,
  "skip-category|sc" => \$skip_category,
  "skip-object|so"   => \$skip_object,
  "skip-datatype|sd" => \$skip_datatype,
  "skip-template|st" => \$skip_template,
  "skip-form|sf" => \$skip_form,
  "dry-run|n"        => sub {$skip_import=$skip_category=$skip_object=$skip_datatype=$skip_template=$skip_form=1},
) or die "GetOptions error";


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
  boolean => 'String', #'Boolean', # FIXME Boolean is documented to work in SMW, but doesn't
  date    => 'Date',
);


# boilerplate text to wrap around templates and forms
my $template_preamble = "<noinclude>\nEdit the page to see the template text.\n</noinclude><includeonly>";
my $template_postamble = "</includeonly>";
# trailing newline is important -- the Semantic Forms <noinclude> parser is a bit too strict
my $form_preamble = "<noinclude>\nEdit the page to see the form text.\n</noinclude><includeonly>\n";
my $form_postamble = <<FORM_POSTAMBLE;
'''Free text:'''

{{{field|free text}}}

<p>{{{standard input|summary}}}</p>
<p>{{{standard input|minor edit}}} {{{standard input|watch}}}</p>
<p>{{{standard input|save}}} {{{standard input|preview}}} {{{standard input|changes}}} {{{standard input|cancel}}}</p>
</includeonly>
FORM_POSTAMBLE


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


# ----------------------------------------
# translate owl:Class to SMW Category.
foreach my $uri ( map($_->subject->as_string,
                      $rdf->get_statements(undef, RDF_TYPE, 'owl:Class')) )
{
  my $obj = $rdf->get_object($uri);
  my $id = uri_split($uri, $ontology_ns) or next;

  my $label = $obj->rdfs_label or
    die "error: no rdfs:label given for '$uri'\n";
  my $uc_label = ucfirst($label);

  print "category: $label\n";
  my $page_text = '';

  if ( defined (my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This category represents [[imported from::$prefix:$id]].";

  if ( $obj->rdfs_subClassOf )
  {
    my $superclass = $obj->rdfs_subClassOf->rdfs_label;
    print "  superclass: $superclass\n";
    $page_text .= " It is a subclass of [[:Category:$superclass|$superclass]].";
    $page_text .= " [[Category:$superclass]] ";
  }

  my $abbrev = $obj->sbwiki_abbreviation;
  if ( $abbrev )
  {
    print "  abbreviation: $abbrev\n";
    $page_text .= " Its abbreviation is [[abbreviation::$abbrev|$abbrev]].";
  }
  else
  {
    my $ancestor = $obj->rdfs_subClassOf;
    my $ancestor_label = '!!ERROR!!';
    while ( $ancestor and !$abbrev )
    {
      $abbrev = $ancestor->sbwiki_abbreviation;
      $ancestor_label = $ancestor->rdfs_label;
      $ancestor = $ancestor->rdfs_subClassOf;
    }
    if ( $abbrev )
    {
      print "  abbreviation: $abbrev (from $ancestor_label)\n";
      $page_text .= " Its abbreviation is [[abbreviation::$abbrev|$abbrev]] (inherited from [[:Category:$ancestor_label|$ancestor_label]]).";
    }
  }

  $page_text .= "\n\n";

  if ( $obj->sbwiki_virtual eq 'true' )
  {
    print "  virtual\n";
    $page_text .= "[[Image:Warning.png]] '''$uc_label''' is [[virtual::true|virtual]], meaning that there are no instances of it, only of its subcategories.\n";
  }
  else
  {
    $page_text .= "[[has default form::Form:$label| ]]\n";
    $page_text .= "[[Image:Add.png]] [{{fullurl:Special:AddDataUID|type_code={{urlencode:$abbrev}}&form={{urlencode:$label}}&lock_core_fields=1}} Create a new '''$label''']\n\n";
  }

  $page_text .= "[[Image:Ontobrowser.gif]] [{{fullurl:Special:OntologyBrowser|entitytitle={{PAGENAMEE}}&ns={{NAMESPACEE}}}} Open '''$label''' in the OntologyBrowser]\n\n";

  my $template_text = "[[Category:$label]]\n{| {{Categoryhelper_table_options}}\n! colspan=\"2\" {{Categoryhelper_table_title_options}} | [[:Category:$label|$uc_label]]\n";
  $template_text = $template_preamble . $template_text . $template_postamble;

  my $form_text = "{{{for template|Category $label}}}{{{end template}}}\n";
  $form_text .= "<table>\n";
  my @properties = map(domain_to_properties($rdf, $_), ancestors($rdf, $obj));
  my %seen;
  @properties = grep { !$seen{$_->object_uri->as_string}++ } @properties;
  $form_text .= properties_to_formtext($rdf, grep(!is_object_nonfunctional_prop($rdf, $_), @properties));
  $form_text .= "</table>\n";
  $form_text .= properties_to_formtext($rdf, grep(is_object_nonfunctional_prop($rdf, $_), @properties));
  $form_text .= "{{{for template|Categoryhelper table end}}}{{{end template}}}\n";
  $form_text = $form_preamble . $form_text . $form_postamble;

  # create category
  unless ( $skip_category )
  {
    $wiki->edit("Category:$label", $page_text, $edit_summary);
    # for virtual classes, skip template/form since their sole purpose is instance editing
    unless ( $obj->sbwiki_virtual eq 'true' )
    {
      $wiki->edit("Template:Category_$label", $template_text, $edit_summary) unless $skip_template;
      $wiki->edit("Form:$label", $form_text, $edit_summary) unless $skip_form;
    }
  }

  $import_text .= " $id|Category\n";
}

print "\n";


# ----------------------------------------
# translate owl:ObjectProperty to SMW Property, with Type:Page.
# also create a fragmentary template for use with Semantic Forms.
my @object_property_uris =
  map($_->subject->as_string,
      $rdf->get_statements(undef, RDF_TYPE, 'owl:ObjectProperty'));
foreach my $uri ( @object_property_uris )
{
  my $obj = $rdf->get_object($uri);
  my $id = uri_split($uri, $ontology_ns) or next;

  my $label = $obj->rdfs_label or
    die "error: no rdfs:label given for '$uri'\n";

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
  my $page_text = '';

  if ( defined (my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This property represents [[imported from::$prefix:$id]].";
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

  my $nice_label = nice_property_label($label);
  my $param_name = label_to_param($nice_label);
  my $template_text = "|-\n! $nice_label\n| [[${label}::{{{$param_name|}}}]]";
  $template_text = $template_preamble . $template_text . $template_postamble;

  # create property
  unless ( $skip_object )
  {
    $wiki->edit("Property:$label", $page_text, $edit_summary);
    # create template
    unless ( $skip_template )
    {
      $wiki->edit("Template:Property_$label", $template_text, $edit_summary);
    }
  }


  $import_text .= " $id|Type:Page\n";
}

print "\n";


# ----------------------------------------
# translate owl:DatatypeProperty to SMW Property, with Type based on the XSD type.
# also create a fragmentary template for use with Semantic Forms.
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

  my $label = $obj->rdfs_label or
    die "error: no rdfs:label given for '$uri'\n";

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
  my $page_text = '';

  if ( defined(my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This property represents [[imported from::$prefix:$id]].";
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

  my $param_name = label_to_param($label);
  my $template_text = "|-\n! $label\n| ";
  # functional properties get a single value entry field, non-functionals support comma-separated lists
  if ( $rdf->exists($uri, RDF_TYPE, 'owl:FunctionalProperty') )
  {
    $template_text .= "{{#if:{{{$param_name|}}}|[[${label}::{{{$param_name|}}}]]}}";
  }
  else
  {
    $template_text .= "{{#arraymap:{{{$param_name|}}}|,|XXXXXXXXXX|[[${label}::XXXXXXXXXX]]}}";
  }
  $template_text = $template_preamble . $template_text . $template_postamble;

  # create property
  unless ( $skip_datatype )
  {
    $wiki->edit("Property:$label", $page_text, $edit_summary);
    # create template, unless this is an AnnotationProperty
    unless ( $skip_template or $rdf->exists($uri, RDF_TYPE, 'owl:AnnotationProperty') )
    {
      $wiki->edit("Template:Property_$label", $template_text, $edit_summary);
    }
  }

  $import_text .= " $id|Type:$smw_type\n";
}

print "\n";


# ----------------------------------------
print "final SMW import\n";
# create "magic" import page
unless ( $skip_import )
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



# Find all properties with $class or its ancestors in their domain
# rdf   : RDF::Helper
# class : RDF::Helper::Object
# returns a list of ::Object
sub domain_to_properties
{
  my ($rdf, $class) = @_;

  my @properties;

  push @properties, map($_->subject, $rdf->get_statements(undef, RDFS_DOMAIN, $class->object_uri));

  # find all rdf:list nodes which contain $class
  my @list_nodes = map($_->subject,
                       $rdf->get_statements(undef, RDF_FIRST, $class->object_uri));
  foreach my $node ( @list_nodes )
  {
    # walk back up past the head of the list, to determine whether the
    # list is the object of a unionOf relation, or not
    until ( $rdf->exists(undef, 'owl:unionOf', $node) or !$rdf->exists($node, RDF_TYPE, RDF_LIST) )
    {
      $node = ($rdf->get_statements(undef, RDF_REST, $node))[0]->subject;
    }
    # if it's a union, grab all properties whose domain is the union
    if ( my @statements = $rdf->get_statements(undef, 'owl:unionOf', $node) )
    {
      my $union = $statements[0]->subject;
      push @properties, map($_->subject, $rdf->get_statements(undef, RDFS_DOMAIN, $union));
    }
  }

  # turn uris into RDF::Helper::Objects
  @properties = map ($rdf->get_object($_), @properties);

  ###print "+++ PROPERTIES WHOSE DOMAIN IS $class\n", map("  ".$_->object_uri->as_string."\n", @properties), "---\n";

  return @properties;
}



# Returns all ancestors of the specified classes (and the classes
# themselves).
# classes : list of RDF::Helper::Objects
# returns a list of ::Objects
sub ancestors
{
  my ($rdf, @classes) = @_;

  # NB: we append to the array as we iterate!
  foreach my $class ( @classes )
  {
    push @classes, $class->rdfs_subClassOf unless !defined $class;
  }

  # remove undefs and duplicates, and flip the order to put parents before children
  # (not necessarily correct in the face of multiple inheritance or multiple inputs)
  my %seen;
  @classes = reverse grep { defined $_ and !$seen{$_}++ } @classes;

  return @classes;
}



# Create a more friendly-to-read version of an ObjectProperty label.
# If the name adheres to the hasNoun/isNounOf convention, strip the
# prefix to leave just the noun(of) part.  Shouldn't change a
# DatatypeProperty label at all since they shouldn't use the has/is
# convention.
sub nice_property_label
{
  my ($label) = @_;

  $label =~ s/^(has|is)\s+//i;

  return $label;
}



# Turn a label into a good template parameter name, by converting to
# lower case and converting spaces into underscores.
sub label_to_param
{
  my ($label) = @_;

  $label = lc($label);
  $label =~ tr/ /_/;

  return $label;
}



sub properties_to_formtext
{
  my ($rdf, @properties) = @_;

  my $form_text;

  foreach my $property ( @properties )
  {
    my $property_label = $property->rdfs_label or
      die "error: no rdfs:label given for '".$property->object_uri."'\n";
    #$DB::single=1 if $property_label eq 'has target protein';
    my $nice_label = nice_property_label($property_label);
    my $param_name = label_to_param($nice_label);
    my $multiple = "";
    my $autocomplete = "";

    if ( is_object_nonfunctional_prop($rdf, $property) )
    {
      $multiple = "multiple|label=$nice_label";
    }
    if ( is_object_prop($rdf, $property) )
    {
      # ucfirst required, otherwise categories wouldn't match (the
      # SemanticForms autocompletion logic should do this itself!)
      my $range_category = ucfirst($property->rdfs_range->rdfs_label);
      $autocomplete = "autocomplete on category=$range_category|remote autocompletion";
    }

    my $field_text = "{{{field|$param_name|$autocomplete}}}";
    $field_text = "<p>$field_text</p>" if $multiple;

    $form_text .= "<tr><th>$nice_label:</th><td>$field_text</td></tr>";
    $form_text .= "{{{for template|Property $property_label|$multiple}}}";
    $form_text .= $field_text;
    $form_text .= "{{{end template}}}\n";
  }

  return $form_text;
}



# Tests to see if a property is an ObjectProperty but not Functional.
# (i.e., needs to use the Semantic Forms "multiple" capability)
sub is_object_nonfunctional_prop
{
  my ($rdf, $property) = @_;

  return $rdf->exists($property->object_uri, RDF_TYPE, 'owl:ObjectProperty') and
    !$rdf->exists($property->object_uri, RDF_TYPE, 'owl:FunctionalProperty');
}



sub is_object_prop
{
  my ($rdf, $property) = @_;

  return $rdf->exists($property->object_uri, RDF_TYPE, 'owl:ObjectProperty');
}



# FIXME info card should display object_nonfunctional props as a list
# in one cell instead of in multiple cells with duplicate labels
#
# {{#ask: [[{{FULLPAGENAME}}]] | ?has source organism = }}
