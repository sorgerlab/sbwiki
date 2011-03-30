#!/usr/bin/perl

use strict;
use MediaWiki::Bot;


my $protocol = 'https';
my $host = 'dev.pipeline.med.harvard.edu';
my $path = 'wiki';
my $username = 'Ontologybot';
my $password = 'bot7';
print "connecting to $protocol://$username\@$password:$host/$path\n\n";
my $bot = MediaWiki::Bot->new({
  protocol => $protocol,
  host => $host,
  path => $path,
  login_data => { username => $username, password => $password },
  debug => 2,
});
$bot or die "error: could not log into wiki:\n", $bot->{errstr};

my %namespaces = reverse $bot->get_namespace_names;

print "deleting pages\n=====\n";

foreach my $page ($bot->get_pages_in_namespace($namespaces{Category}, 5000))
{
  print "$page\n";
  $DB::single=1;
  $bot->delete($page, 'cleaning up ontology imports');
  check_error();
}

foreach my $page ($bot->get_pages_in_namespace($namespaces{Template}, 5000))
{
  next if $page !~ /^Template:(Category|Property|PropertyPrefix) /;
  print "$page\n";
  $bot->delete($page, 'cleaning up ontology imports');
}

foreach my $page ($bot->get_pages_in_namespace($namespaces{Property}, 5000))
{
  next if grep($page eq "Property:$_", qw(Initials));
  print "$page\n";
  $bot->delete($page, 'cleaning up ontology imports');
}


sub check_error
{
  if (defined $bot->{error})
  {
    print "ERROR (#$bot->{error}{code}) $bot->{error}{details}\n";
  }
}
