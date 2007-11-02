#!/usr/bin/perl

use strict;
use Text::BibTeX;
use Data::Dumper;


my ($input_file, $bibtex_file) = @ARGV;
if (!defined $input_file or !defined $bibtex_file )
{
  die "usage: filter_bibtexref2pmid.pl infile refs.bib\n";
}


my %citations = build_citation_dict($bibtex_file);
print Dumper(\%citations);

open(IN, $input_file) or die "$input_file: $!\n";
close(IN);



#############################################

sub build_citation_dict
{
  my ($bibtex_file) = @_;

  my $bibfile = Text::BibTeX::File->new($bibtex_file);
  my %citations;
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
      $wikitext = $entry->get('pmid');
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
  }

  return %citations;
}
