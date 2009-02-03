#!/usr/bin/perl

use strict;
use IO::All;
use Perlwikipedia;


my $wiki = Perlwikipedia->new;
$wiki->set_wiki('https://dev.pipeline.med.harvard.edu', '/wiki');
$wiki->login('Username', 'password') == 0
  or die "error: could not log into wiki:\n", $wiki->{errstr};

my @pages = io('pages')->chomp->slurp;
foreach my $page (@pages)
{
  print "$page\n";
  $wiki->get_text($page) or next;
  $wiki->delete_page($page, 'failed import');
}

