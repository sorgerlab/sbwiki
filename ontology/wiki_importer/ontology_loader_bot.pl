#!/usr/bin/perl

# FIXME: need to create stuff in the right order, or force SMW refresh
#   (e.g. Property:Abbreviation before Categories, since they use Abbrevs)

use strict;
use Getopt::Long;
use RDF::Helper;
use RDF::Helper::Constants qw(:rdf :rdfs);
use Perlwikipedia;
use POSIX;


my ($skip_import, $skip_category, $skip_object, $skip_datatype, $skip_template, $skip_form);
my ($wiki_url, $wiki_scriptpath, $wiki_username, $wiki_password);
my $xml = 1;
my $minor = 1;

# NB: add new skip_* parameters to the dry-run line at the bottom
#   (could probably do this programatically if I read up on Getopt)
GetOptions(
  "xml!"                 => \$xml,
  "minor!"               => \$minor,
  "wiki-url|wu=s"        => \$wiki_url,
  "wiki-scriptpath|ws=s" => \$wiki_scriptpath,
  "wiki-username|wn=s"   => \$wiki_username,
  "wiki-password|wp=s"   => \$wiki_password,
  "skip-import|si"       => \$skip_import,
  "skip-category|sc"     => \$skip_category,
  "skip-object|so"       => \$skip_object,
  "skip-datatype|sd"     => \$skip_datatype,
  "skip-template|st"     => \$skip_template,
  "skip-form|sf"         => \$skip_form,
  "dry-run|n"            => sub {$skip_import=$skip_category=$skip_object=$skip_datatype=$skip_template=$skip_form=1},
) or die "GetOptions error";


my ($owl_filespec, @owl_extra_filespecs) = @ARGV;
defined $owl_filespec  or die "error: no OWL filespec given\n";


if ( $xml )
{
  defined $wiki_username   or die "error: no --wiki-username given (used as import contributor name)\n"
}
else
{
  my $err;
  defined $wiki_url        or $err=1, warn "error: no --wiki-url given\n";
  defined $wiki_scriptpath or $err=1, warn "error: no --wiki-scriptpath given\n";
  defined $wiki_username   or $err=1, warn "error: no --wiki-username given\n";
  defined $wiki_password   or $err=1, warn "error: no --wiki-password given\n";
  exit 1 if $err;
}

# force this to make bot module happy and since mediawiki generally likes it this way
$wiki_username = ucfirst($wiki_username);

# end of option parsing


my $wiki;
if ( $xml )
{
  print qq{<mediawiki version="0.3" xml:lang="en" xmlns="http://www.mediawiki.org/xml/export-0.3/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.mediawiki.org/xml/export-0.3/ http://www.mediawiki.org/xml/export-0.3.xsd">\n};
}
else
{
  $wiki = Perlwikipedia->new;
  $wiki->set_wiki($wiki_url, $wiki_scriptpath);
  $wiki->login($wiki_username, $wiki_password) == 0
    or die "error: could not log into wiki:\n", $wiki->{errstr}, "\n";
}


my $timestamp = POSIX::strftime('%Y-%m-%dT%H:%M:%SZ', gmtime);


# parse remaining tokens as our filespecs (see parse_owl_filespec)
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
# load all owl files
foreach my $filename ( map($_->{filename}, @owl_filespec_data) )
{
  $rdf->include_rdfxml(filename => $filename);
}

# verify imports have been loaded
foreach my $uri ( map($_->object->as_string,
                      $rdf->get_statements(undef, 'owl:imports', undef)) )
{
  if ( ! grep($_->{uri} eq $uri, @owl_filespec_data) )
  {
    die "OWL file specification not provided for imported ontology: $uri\n";
  }
}


my %xsd_smw_types = (
  string  => 'String',
  int     => 'Number',
  float   => 'Number',
  boolean => 'String', #'Boolean', # FIXME Boolean is documented to work in SMW, but doesn't
  date    => 'Date',
);


# boilerplate text to wrap around templates and forms
my $template_pre  = "<noinclude>\nEdit the page to see the template text.\n</noinclude><includeonly>";
my $template_post = "</includeonly>";
# trailing newline is important -- the Semantic Forms <noinclude> parser is a bit too strict
my $form_pre  = "<noinclude>\nEdit the page to see the form text.\n</noinclude><includeonly>\n";
my $form_post = <<FORM_POST;
'''Free text:'''

{{{field|free text}}}

<p>{{{standard input|summary}}}</p>
<p>{{{standard input|minor edit}}} {{{standard input|watch}}}</p>
<p>{{{standard input|save}}} {{{standard input|preview}}} {{{standard input|changes}}} {{{standard input|cancel}}}</p>
</includeonly>
FORM_POST


my $prefix = $owl_filespec_data[0]->{prefix};
my $ontology_ns = join('', @{$owl_filespec_data[0]}{qw(uri separator)});


my $edit_summary = "OWL import from '" . $owl_filespec_data[0]->{filename} . "'";

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

  log_msg("category: $label");
  my $page_text = '';

  if ( defined (my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This category represents [[imported from::$prefix:$id]].";

  if ( $obj->rdfs_subClassOf )
  {
    my $superclass = $obj->rdfs_subClassOf->rdfs_label;
    log_msg("  superclass: $superclass");
    $page_text .= " It is a subclass of [[:Category:$superclass|$superclass]].";
    $page_text .= " [[Category:$superclass]] ";
  }

  my $abbrev = $obj->ssw_abbreviation;
  if ( $abbrev )
  {
    log_msg("  abbreviation: $abbrev");
    $page_text .= " Its abbreviation is [[abbreviation::$abbrev|$abbrev]].";
  }
  else
  {
    my $ancestor = $obj->rdfs_subClassOf;
    my $ancestor_label = '!!ERROR!!';
    while ( $ancestor and !$abbrev )
    {
      $abbrev = $ancestor->ssw_abbreviation;
      $ancestor_label = $ancestor->rdfs_label;
      $ancestor = $ancestor->rdfs_subClassOf;
    }
    if ( $abbrev )
    {
      log_msg("  abbreviation: $abbrev (from $ancestor_label)");
      $page_text .= " Its abbreviation is [[abbreviation::$abbrev|$abbrev]] (inherited from [[:Category:$ancestor_label|$ancestor_label]]).";
    }
  }

  $page_text .= "\n";

  if ( $obj->ssw_isVirtual )
  {
    log_msg("  virtual");
    $page_text .= "[[Image:Warning.png]] '''$uc_label''' is [[isVirtual::true|virtual]], meaning that there are no instances of it, only of its subcategories.\n";
  }
  else
  {
    $page_text .= "[[has default form::Form:$label| ]]\n";
    $page_text .= "[[Image:Add.png]] [{{fullurl:Special:AddDataUID|category={{urlencode:$label}}}} Create a new '''$label''']\n\n";
  }

  # FIXME re-enable ontology browser in the wiki then uncomment this next line
  #$page_text .= "[[Image:Ontobrowser.gif]] [{{fullurl:Special:OntologyBrowser|entitytitle={{PAGENAMEE}}&ns={{NAMESPACEE}}}} Open '''$label''' in the OntologyBrowser]\n\n";

  my $template_text = "[[Category:$label]]\n{| {{Categoryhelper_table_options}}\n! colspan=\"2\" {{Categoryhelper_table_title_options}} | [[:Category:$label|$uc_label]]\n";
  $template_text = $template_pre . $template_text . $template_post;

  my $form_text = "{{{for template|Category $label}}}{{{end template}}}\n";
  $form_text .= "<table>\n";
  my @properties = map(domain_to_properties($rdf, $_), ancestors($rdf, $obj));
  my %seen;
  #$DB::single=1 if $label eq 'physicochemical reaction'; # XXX
  @properties = grep { !$seen{$_->object_uri->as_string}++ } @properties;
  $form_text .= properties_to_formtext($rdf, grep(!is_object_nonfunctional_prop($rdf, $_), @properties));
  $form_text .= properties_to_formtext($rdf, grep(is_object_nonfunctional_prop($rdf, $_), @properties));
  $form_text .= "</table>\n";
  $form_text .= "{{{for template|Categoryhelper table end}}}{{{end template}}}\n";
  $form_text = $form_pre . $form_text . $form_post;

  # create category
  unless ( $skip_category )
  {
    edit_page("Category:$label", $page_text);
    # for virtual classes, skip template/form since their sole purpose is instance editing
    unless ( $obj->ssw_isVirtual )
    {
      edit_page("Template:Category_$label", $template_text) unless $skip_template;
      edit_page("Form:$label", $form_text) unless $skip_form;
    }
  }

  $import_text .= " $id|Category\n";
}
log_msg();


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

  my $range_label  = defined $obj->rdfs_range ? $obj->rdfs_range->rdfs_label : undef;

  log_msg("object property: $label");
  my $page_text = '';

  if ( defined (my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This property represents [[imported from::$prefix:$id]].";
  if ( $obj->rdfs_subPropertyOf )
  {
    my $superproperty = $obj->rdfs_subPropertyOf->rdfs_label;
    log_msg("  superproperty: $superproperty");
    $page_text .= " It is a subproperty of [[subproperty of::Property:$superproperty|$superproperty]].";
  }
  if (@domain_labels)
  {
    log_msg("  domain: @domain_labels");
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
    log_msg("  range: $range_label");
    $page_text .= " Its range is [[has_range_hint::Category:$range_label|$range_label]].";
  }

  my $nice_label = nice_property_label($label);
  my $param_name = label_to_param($nice_label);
  # prefix will be inserted once by the form, main template gets one copy per instance of the property
  my $template_prefix_text = $template_pre . "|-\n! $nice_label\n| " . $template_post;
  my $template_text =
    "{{#if:{{{$param_name|}}}|" .
    "<p>[[${label}::{{{$param_name}}}]]</p>" .
    '}}';
  # TODO: add queries for selected properties on object:
  # {{#ifexist:{{{$param_name}}}
  #   ({{#ask: [[{{{$param_name}}}]]|?$object_prop_name|format=list}};[etc])
  # }}
  $template_text = $template_pre . $template_text . $template_post;


  # create property
  unless ( $skip_object )
  {
    edit_page("Property:$label", $page_text);
    # create template
    unless ( $skip_template or $obj->ssw_isHidden )
    {
      edit_page("Template:PropertyPrefix_$label", $template_prefix_text);
      edit_page("Template:Property_$label", $template_text);
    }
  }


  $import_text .= " $id|Type:Page\n";
}

log_msg();



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
        "' on datatype property '$uri'\n");
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

  log_msg("datatype property: $label");
  my $page_text = '';

  if ( defined(my $comment = $obj->rdfs_comment) )
  {
    $page_text .= $comment . "\n\n";
  }

  $page_text .= "This property represents [[imported from::$prefix:$id]].";
  if ( $obj->rdfs_subPropertyOf )
  {
    my $superproperty = $obj->rdfs_subPropertyOf->rdfs_label;
    log_msg("  superproperty: $superproperty");
    $page_text .= " It is a subproperty of [[subproperty of::Property:$superproperty|$superproperty]].";
  }
  if (@domain_labels)
  {
    log_msg("  domain: @domain_labels");
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

  log_msg("  range: $smw_type");
  $page_text .= " Its range is literal [[has_type::$smw_type]] values.";

  my $param_name = label_to_param($label);
  my $template_text = "|-\n! $label\n| ";
  # functional properties get a single value entry field, non-functionals support delimited lists
  if ( $rdf->exists($uri, RDF_TYPE, 'owl:FunctionalProperty') )
  {
    $template_text .= "{{#if:{{{$param_name|}}}|[[${label}::{{{$param_name|}}}]]}}";
  }
  else
  {
    $template_text .= "{{#arraymap:{{{$param_name|}}}|;|XXXXXXXXXX|[[${label}::XXXXXXXXXX]]|&nbsp;;&nbsp;}}";
  }
  $template_text = $template_pre . $template_text . $template_post;

  # create property
  unless ( $skip_datatype )
  {
    edit_page("Property:$label", $page_text);
    # create template, unless this is an AnnotationProperty
    unless ( $skip_template or $obj->ssw_isHidden or
	     $rdf->exists($uri, RDF_TYPE, 'owl:AnnotationProperty') )
    {
      edit_page("Template:Property_$label", $template_text);
    }
  }

  $import_text .= " $id|Type:$smw_type\n";
}

log_msg();


# ----------------------------------------
log_msg("final SMW import");
# create "magic" import page
unless ( $skip_import )
{
  edit_page($import_title, $import_text);
}



if ( $xml )
{
  print qq{</mediawiki>\n};
}
log_msg();
log_msg("Done");



# ============================================================



sub log_msg
{
  print STDERR @_, "\n";
}



# parse command line params of the format filename:prefix:uri
# (uri must include trailing # or /)
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



sub edit_page
{
  my ($title, $text) = @_;

  if ( $xml )
  {
    my $minor_text = "<minor/>";
    print <<XML_PAGE;
  <page>
    <title>$title</title>
    <revision>
      <timestamp>$timestamp</timestamp>
      <contributor>
        <username>$wiki_username</username>
      </contributor>
      $minor_text
      <comment><![CDATA[$edit_summary]]></comment>
      <text xml:space="preserve"><![CDATA[$text]]></text>
    </revision>
  </page>
XML_PAGE
  }
  else
  {
    $wiki->edit($title, $text, $edit_summary);
  }
}



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
    next if $property->ssw_isHidden;

    my $property_label = $property->rdfs_label or
      die "error: no rdfs:label given for '".$property->object_uri."'\n";
    #$DB::single=1 if $property_label eq 'has target protein';
    my $nice_label = nice_property_label($property_label);
    my $param_name = label_to_param($nice_label);
    my $multiple = "";
    my $autocomplete = "";
    my $info_text = "";

    if ( is_object_prop($rdf, $property) )
    {
      if ( !is_functional_prop($rdf, $property) )
      {
	$multiple = "multiple|label=$nice_label";
      }
      # ucfirst required, otherwise categories wouldn't match (the
      # SemanticForms autocompletion logic should do this itself!)
      my $range_category = ucfirst($property->rdfs_range->rdfs_label);
      $autocomplete = "autocomplete on category=$range_category|remote autocompletion";
      # insert prefix form
      $form_text .= "{{{for template|PropertyPrefix $property_label}}}{{{end template}}}";
    }
    else # datatype
    {
      $info_text = "semicolon; delimited; list" if !is_functional_prop($rdf, $property);
    }

    my $field_text = "{{{field|$param_name|$autocomplete}}}";
    $field_text = "<p>$field_text</p>" if $multiple;

    $form_text .= "<tr>";
    $form_text .= "<th>$nice_label</th>";
    $form_text .= "<td>{{{for template|Property $property_label|$multiple}}}${field_text}{{{end template}}}</td>";
    $form_text .= "<td>$info_text</td>";
    $form_text .= "</tr>\n";
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



sub is_functional_prop
{
  my ($rdf, $property) = @_;

  return $rdf->exists($property->object_uri, RDF_TYPE, 'owl:FunctionalProperty');
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
