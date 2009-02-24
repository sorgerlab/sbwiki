#!/usr/bin/perl

# Converts a mediawiki export xml file from the ontology used at the
# time Brian originally wrote his import script, to the current
# ontology as of 2009-02-23.

# This doesn't actually parse the XML, so I had to play some regex
# tricks in a couple of places to make sure my substitutions are
# applied in the right places.  If this gets any more complex then it
# should be modified to perform real XML parsing.

# TODO: In trail-wiki_export-20080922.xml, params for synth/deg rxns
# are all named ks,kr.  Need to rename them or something.  They are
# all zero except for r68 (0 <--> M*).

# TODO: Deal with non-editable properties correctly, since they have
# no associated templates anymore.  Produce explicit display/link
# text.


use strict;
use POSIX;
use Getopt::Long;
use Data::Dumper;


length($ARGV[0]) and length($ARGV[1]) or
  die("usage: $0 original_dump.xml param_uids.txt\n");


open(XMLFILE, $ARGV[0]) or die("$ARGV[0]: $!\n");
my $content = join('', <XMLFILE>);
close(XMLFILE);


my %parameter_uids;
my $line_number = 1;
open(UIDFILE, $ARGV[1]) or die("$ARGV[1]: $!\n");
while (my $uid = <UIDFILE>)
{
  chomp $uid;
  (my ($annotation) = $uid =~ /^PA-[A-Z]{2,3}-\d+-(.+)/) or
    die("Error in $ARGV[1] line $line_number: bad UID syntax\n");
  $parameter_uids{$annotation} = $uid;
  $line_number++;
}
close(UIDFILE);


my $timestamp = POSIX::strftime('%Y-%m-%dT%H:%M:%SZ', gmtime);
$content =~ s|(?<=<timestamp>).*?(?=</timestamp>)|$timestamp|g;


# grab model UID
my ($model_uid) = $content =~ m|<title>(MD-.*?)</title>|;

# for model_interaction, RX is now IX.
# properties
$content =~ s/::RX-/::IX-/g;
# page titles
$content =~ s/<title>RX-/<title>IX-/g;

# gather parameter names and values here as we go
my @parameters;

# fix reaction templates
my $ix_re = qr/{{Physicochemical_reaction\s*\|name=(.*?)\s*\|mass action=(.*?)\s*\|parameters=(.*?)\s*\|references=(.*?)\s*}}/s;
my %ix_fields;
while ( @ix_fields{qw(name mass_action params refs)} = $content =~ $ix_re )
{
  # turn params into an array-of-arrays of [name, value] pairs
  $ix_fields{params} = [ map { [ split(/\s*=\s*/, $_) ] } list_split($ix_fields{params}) ];
  # store params in global params list
  push @parameters, @{$ix_fields{params}};
  # turn refs into a semicolon-separated string
  $ix_fields{refs} = join('; ', list_split($ix_fields{refs}));

  # TODO: reorder params nicely?
  my $new_content = <<CONTENT_END;
{{Category physicochemical reaction}}
{{Property label
|label=$ix_fields{name}
}}
{{Property mass action formula
|mass_action_formula=$ix_fields{mass_action}
}}
{{Property literature reference
|literature_reference=$ix_fields{refs}
}}
{{Categoryhelper table end}}
CONTENT_END

  $content =~ s/$ix_re/$new_content/;

  my $context_re = qr/{{Category physicochemical reaction}}\n{{Property label\n\|label=\Q$ix_fields{name}\E\n/;
  my $parent_link_dynamic = "This reaction is part of the model '[[$model_uid]]'";
  my $params_content = '';
  foreach my $param ( @{$ix_fields{params}} ) {
    my $param_uid = $parameter_uids{$param->[0]};
    $params_content .= "[[has kinetic parameter::$param_uid| ]]\n";
  }
  $content =~ s/(?<=$context_re)(.*?)\[\[part of model::.*?\| \]\]/$1$params_content$parent_link_dynamic/s;
}


# fix species templates
my $sp_re = qr/{{Physicochemical_species\s*\|name=(.*?)\s*\|synonyms=(.*?)\s*\|full_name=(.*?)\s*\|uniprot=(.*?)\s*\|molecule_type=(.*?)\s*\|localization=(.*?)\s*\|initial_value=(.*?)\s*\|references=(.*?)\s*}}/s;
my %sp_fields;
while ( @sp_fields{qw(name synonyms full_name uniprot molecule_type localization initial_value references)} =
	$content =~ $sp_re )
{
  # change to new semicolon separator
  $sp_fields{synonyms} =~ tr/,/;/;
  # turn references into a semicolon-separated string
  $sp_fields{references} = join('; ', list_split($sp_fields{references}));

  my $new_content = <<CONTENT_END;
{{Category physicochemical species}}
{{Property label
|label=$sp_fields{name}
}}
{{Property full name
|full_name=$sp_fields{full_name}
}}
{{Property synonym
|synonym=$sp_fields{synonyms}
}}
{{Property literature reference
|literature_reference=$sp_fields{references}
}}
CONTENT_END
  $new_content .= "{{Categoryhelper table end}}\n";

  if ( $sp_fields{uniprot} )
  {
    $new_content .= "''UniProt accession number'': [http://www.uniprot.org/uniprot/$sp_fields{uniprot} $sp_fields{uniprot}].\n";
  }
  if ( $sp_fields{molecule_type} )
  {
    $new_content .= "''Molecule type'': $sp_fields{molecule_type}.\n";
  }
  if ( $sp_fields{localization} )
  {
    $new_content .= "''Localization'': $sp_fields{localization}.\n";
  }
  $new_content .= "\n";

  $content =~ s/$sp_re/$new_content/;

  my $context_re = qr/{{Category physicochemical species}}\n{{Property label\n\|label=\Q$sp_fields{name}\E\n/;
  my $parent_link_dynamic = "This species is part of the model '[[$model_uid]]'";
  my $param_content = '';
  if ( length($sp_fields{initial_value}) )
  {
    my $param_uid = $parameter_uids{$sp_fields{name}.'_0'};
    $param_content = "[[has initial condition::$param_uid| ]]\n";
    # store params in global params list
    push @parameters, map( [ "$sp_fields{name}_0", $_ ], $sp_fields{initial_value} );
  }
  $content =~ s/(?<=$context_re)(.*?)\[\[part of model::.*?\| \]\]/$1$param_content$parent_link_dynamic/s;
}

# in species pages, fix up reaction links in reaction descriptions
# (SMW parser issues I guess?)
$content =~ s/\|\[\d+\](?=\]\]:)//g;


# create <page> blocks for parameters
my $param_content = '';
foreach my $parameter ( @parameters )
{
  my ($label, $value) = @$parameter;
  my $uid = $parameter_uids{$label};
  $param_content .= <<PARAM_PAGE;
  <page>
    <title>$uid</title>
    <revision>
      <timestamp>$timestamp</timestamp>
      <text xml:space="preserve">{{Category model parameter}}
{{Property label
|label=$label
}}
{{Property parameter value
|parameter_value=$value
}}
{{Categoryhelper table end}}



&lt;!-- the following text was auto-generated by the model importer --&gt;
This parameter is part of the model '[[$model_uid]]'</text>
    </revision>
  </page>
PARAM_PAGE
}
$content =~ s|(?=</mediawiki>)|$param_content|;


# remove 'description' headers
$content =~ s/== Description == *\n//g;

# remove a few xml tags we don't want to carry forward
$content =~ s|^\s*<id>.*?</id>\n||mg;
$content =~ s|^\s*<comment>.*?</comment>\n||mg;
$content =~ s|^\s*<minor.*?/>\n||mg;


# fix property names
my @property_renames =
  (
   ['has component'            , 'has component species'],
   ['makes product'            , 'catalyzes production of'],
   ['has substrate'            , 'has catalytic substrate'],
   ['has participant'          , 'has involved species'],
   ['part of complex'          , 'is component species of'],
   ['product of'               , 'has production catalyzed by'],
   ['substrate of'             , 'is catalytic substrate of'],
   ['converts to'              , 'converted to'],
   ['translocates to'          , 'translocated to'],
   ['participates in reaction' , 'is involved in reaction'],
   ['has reaction'             , 'has model interaction'],
   ['has species'              , 'has model species'],
  );
foreach my $rename ( @property_renames )
{
  $content =~ s/(?<=\[\[)$rename->[0](?=::)/$rename->[1]/g;
}

print $content;


# ======================================


# split a string of newline/whitespace-delimited values and return a list
sub list_split
{
  return split(/\s*\n\s*/, $_[0])
}
