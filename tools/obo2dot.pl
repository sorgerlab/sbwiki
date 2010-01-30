#!/usr/bin/perl

use strict;
use feature "switch";
use Text::Wrap;
use Text::WordDiff;

my %nodes;

my ($id, $name, $skip, @parents);
while (<>) {
  chomp;
  last if $_ eq '';
}
while (<>) {
  chomp;
  given ($_) {
    when (/^\[Term\]/)    { $id = $name = $skip = undef; @parents = () }
    when (/^id: (\S+)/)   { $id = normalize_id($1); $skip = 1 if $id eq 'is_a' }
    when (/^name: (.+)/)  { $name = $1; $name =~ s/\\,/,/g }
    when (/^is_a: (\S+)/) { push @parents, normalize_id($1) }
    when (/^is_obsolete:/){ $skip = 1 }
    when ('')             { unless ($skip) {
                              $nodes{$id} = {
					     id => $id,
					     label => $name,
					     parents => [@parents],
					    }
			    }
			  }
  }
}

$Text::Wrap::columns = 30;
$Text::Wrap::separator = '<br/>';

print "digraph OBO {\n";
print <<GOPTS;
rankdir=RL
GOPTS

foreach my $node (values %nodes) {
  my $id = $node->{id};
  my $label = $node->{label};
  my @parents = @{$node->{parents}};

  if (length($label) > $Text::Wrap::columns and @parents == 1) {
    $label = word_diff(\$nodes{$parents[0]}->{label}, \$label, {STYLE => 'HTML'});
    $label =~ s|</?span[^>]*>||g;
    $label =~ s|</?div[^>]*>||g;
    $label =~ s|<ins>|\x01|g;
    $label =~ s|</ins>|\x02|g;
    $label =~ s|<del>|\x03|g;
    $label =~ s|</del>|\x04|g;
    $label = wrap('', '', $label);
    $label =~ s|\x01|<font color="#00ff00">|g;
    $label =~ s|\x02|</font>|g;
    $label =~ s|\x03|<font color="#ff0000">|g;
    $label =~ s|\x04|</font>|g;
  } else {
    $label = wrap('', '', $label);
  }

  print "${id}[label=<$label>]\n";
  foreach my $parent (@parents) {
    print "$id -> $parent\n"
  }
}

print "}\n";


sub normalize_id {
  my ($id) = @_;
  $id =~ s/:/_/;
  return $id;
}
