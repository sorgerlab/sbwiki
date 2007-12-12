#!/usr/bin/perl

use strict;
use Text::BibTeX;
use POSIX;
use XML::Twig;
use Data::Dumper;


use constant {
  CITE_BEGIN => '\cite{',
  CITE_END   => '}',
};



my ($input_file, $bibtex_file) = @ARGV;
if (!defined $input_file or !defined $bibtex_file )
{
  die "usage: filter_bibtexref2pmid.pl infile refs.bib\n";
}


my ($citations, $references) = parse_references($bibtex_file);

my $twig = XML::Twig->new(pretty_print => 'indented');
$twig->parsefile($input_file);

foreach my $text_elt ( $twig->findnodes('/mediawiki/page/revision/text') )
{
  my $input_content = $text_elt->text;

  my $start_pos;
  my $end_pos = 0;
  my %seen_refs;

  while ( ($start_pos = index($input_content, CITE_BEGIN, $end_pos)) >= 0 )
  {
    $end_pos = index($input_content, CITE_END, $start_pos);
    my $ids_start     = $start_pos + length(CITE_BEGIN);
    my $ids_end       = $end_pos - $ids_start + 1 - length(CITE_END);
    my $citation_text = substr($input_content, $ids_start, $ids_end);
    my @citation_ids      = map { s/\s//g; $_ } split(/,/, $citation_text);
    @seen_refs{@citation_ids} = (1) x @citation_ids;
    my @citation_wikitext;
    foreach my $id ( @citation_ids )
    {
      defined $citations->{$id} or die "Citation id not found in bibtex file: {$id}\n(context: $citation_text)\n";
      push @citation_wikitext, $citations->{$id} ;
    }
    my $cite_wikitext = " (" . join(", ", @citation_wikitext) . ") ";
    substr($input_content, $start_pos, $end_pos - $start_pos + 1) = $cite_wikitext;
    $end_pos = $start_pos + length($cite_wikitext);
  }

  my $ref_text = join("\n\n", @$references{keys %seen_refs});
  $ref_text =~ s/\|/&#124;/g;
  $ref_text =~ tr/{}//d;
  $input_content =~ s/(references=)/$1$ref_text/;

  $text_elt->set_text($input_content);
}

my $timestamp = POSIX::strftime('%Y-%m-%dT%H:%M:%SZ', gmtime);
foreach my $timestamp_elt ( $twig->findnodes('/mediawiki/page/revision/timestamp') )
{
  $timestamp_elt->set_text($timestamp);
}

$twig->flush;


#############################################

sub parse_references
{
  my ($bibtex_file) = @_;

  my $bibfile = Text::BibTeX::File->new($bibtex_file);
  $bibfile->set_structure('Bib');
  my %citations;
  my %references;
  while ( my $entry = Text::BibTeX::Entry->new($bibfile) )
  {
    if ( !$entry->parse_ok )
    {
      warn "entry did not parse\n";
      next;
    }

    my $wikitext = "UNKNOWN REFERENCE";
    if ( $entry->exists('pmid') )
    {
      $wikitext = "PMID " . $entry->get('pmid');
    }
    elsif ( $entry->exists('doi') )
    {
      $wikitext = "[[http://dx.doi.org/" . $entry->get('doi') . "]]";
    }
    elsif ( $entry->exists('isbn') )
    {
      $wikitext = "ISBN " . $entry->get('isbn');
    }
    elsif ( $entry->exists('url') )
    {
      if ( my ($pmid) = $entry->get('url') =~ m|www\.ncbi\.nlm\.nih\.gov/entrez.*?(\d{5,})| )
      {
        $wikitext = "PMID " . $pmid;
      }
      else
      {
        $wikitext = "[[" . $entry->get('url') . "]]";
      }
    }
    else
    {
      warn($entry->key . ": no usable identifier found\n");
    }

    $citations{$entry->key} = $wikitext;
    $references{$entry->key} = format_reference($entry);
  }

  return \%citations, \%references;
}


sub format_reference
{
  my ($entry) = @_;

  my @blocks = $entry->format;

  # the following was borrowed from btformat in the Text::BibTeX distribution
 BLOCK:
  for my $block (@blocks)
  {
  SENTENCE:
    for my $sentence (@$block)
    {
      # If sentence has multiple clauses, process them: first, strip
      # out empties, and jump to the next sentence if it turns out 
      # this one is empty (ie. just a bunch of empty clauses).  Then
      # join the left-over clauses with commas.
      if (ref $sentence eq 'ARRAY')
      {
        @$sentence = grep ($_, @$sentence);
        ($sentence = '', next SENTENCE) unless @$sentence;
        $sentence = join (', ', @$sentence);
      }

      # finish sentence with a period if it's not already punctuated
      $sentence .= '.' unless $sentence eq '' || $sentence =~ /[.!?]$/;
    }

    # Now join together all the sentences in the block, first stripping
    # any empties.
    @$block = grep ($_, @$block);
    next BLOCK unless @$block;
    $block = join (' ', @$block);     # put the sentences together
  }
  my $reference = join(' ', @blocks);

  return $reference;
}
