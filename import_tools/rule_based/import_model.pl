#!/usr/bin/perl

use strict;
use Getopt::Long;
use Perlwikipedia;


my @valid_types = qw(littleb);


my $model_filename = shift(@ARGV);
my $model_type     = shift(@ARGV);
my @wiki_opts      = splice(@ARGV, 0, 2);
my @wiki_login     = splice(@ARGV, 0, 2);

defined $model_filename or
  die "error: no model file given\n";
defined $model_type and grep($_ eq $model_type, @valid_types) or
  die "error: no model type given (choose one: @valid_types)\n";
defined $wiki_opts[1] or
  die "error: must provide wiki url and script path\n";
defined $wiki_login[1] or
  die "error: must provide wiki username and password\n";

my ($dry_run);
GetOptions(
  "dry-run|n"        => \$dry_run,
) or die "GetOptions error";


my $parser_package = "Parser_${model_type}";
require "${parser_package}.pm";
my $parser = $parser_package->new;


#$wiki_login[0] = ucfirst($wiki_login[0]); # force this to make bot module happy
#my $wiki = Perlwikipedia->new;
#$wiki->set_wiki(@wiki_opts);
#$wiki->login(@wiki_login) == 0
#  or die "error: could not log into wiki:\n", $wiki->{errstr}, "\n";


$parser->parse_model($model_filename);
