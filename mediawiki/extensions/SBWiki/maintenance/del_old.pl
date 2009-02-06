#!/usr/bin/perl

use strict;
use IO::All;
use Term::ReadLine;
use Perlwikipedia;



my $term = Term::ReadLine->new;
#		            my $OUT = $term->OUT || \*STDOUT;
my $username = $term->readline('wiki username:');
my $password = $term->readline('wiki password:');
print STDERR "reading page titles from stdin...\n";

my $wiki = Perlwikipedia->new;
$wiki->set_wiki('https://dev.pipeline.med.harvard.edu', '/wiki');
$wiki->login($username, $password) == 0
  or die "error: could not log into wiki:\n", $wiki->{errstr};

my @pages = io('-')->slurp;
foreach my $page (@pages)
{
  $page =~ s/\s+$//;
  $page =~ s/^\s+//;
  print "$page\n";
  $wiki->get_text($page) or next;
  $wiki->delete_page($page, 'failed import');
}

