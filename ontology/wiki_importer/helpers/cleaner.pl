#!/usr/bin/perl

use strict;
use Perlwikipedia;


my $wiki = Perlwikipedia->new;
$wiki->set_wiki('https://dev.pipeline.med.harvard.edu', '/wiki');
$wiki->login('Ontologybot', undef) == 0
  or die "error: could not log into wiki:\n", $wiki->{errstr};

my %namespaces = reverse $wiki->get_namespace_names;

my @pages = $wiki->get_pages_in_namespace($namespaces{Template}, 5000);
foreach my $page (@pages)
{
#  next unless $page =~ /^Template:Property:/;
#  print "$page\n";
#  $wiki->delete_page($page, 'poor naming choice');
}
