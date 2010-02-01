#!/usr/bin/perl

use strict;
use feature "switch";
use Text::Wrap;
use Text::WordDiff;

my %nodes;

my ($id, $name, $skip, @parents);
while (<>) {
  s/\s+$//;
  last if $_ eq '';
}
while (<>) {
  s/\s+$//;
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
node [fontname="DejaVu Sans Condensed"]
GOPTS

my $BEGIN_WORD = qr/(?=\W)/ms;

foreach my $node (values %nodes) {
  my $id = $node->{id};
  my $label = $node->{label};
  my @parents = @{$node->{parents}};
  my $parent_label = $nodes{$parents[0]}->{label};

  my $new_label;

  if (length($label) > $Text::Wrap::columns and @parents == 1 and length($parent_label) > $Text::Wrap::columns) {

    foreach my $str ($label, $parent_label)
    {
      $str = ' ' . $str;
    }
    my @words_node = split($BEGIN_WORD, $label);
    my @words_parent = split($BEGIN_WORD, $parent_label);
    # FIXME debugging, remove
    if ($id eq 'SBO_0000426' or $id eq 'SBO_0000086') {
      use Data::Dumper;
      #print STDERR Dumper(\@words_node, \@words_parent);
    }
    $new_label = word_diff(\@words_parent, \@words_node, {STYLE => 'HTML'});
    $new_label =~ s|</?span[^>]*>||g;
    $new_label =~ s|</?div[^>]*>||g;
    $new_label =~ s|<ins>|\x01|g;
    $new_label =~ s|</ins>|\x02|g;
    $new_label =~ s|<del>|\x03|g;
    $new_label =~ s|</del>|\x04|g;

    my $unchanged = $new_label;
    $unchanged =~ s/\x01[^\x02]+\x02//g;
    $unchanged =~ s/\x03[^\x04]+\x04//g;
    if (length($unchanged) < length($label) / 2) {
      $new_label = $label;
    }

    $new_label = wrap('', '', $new_label);
    $new_label =~ s|\x01|<font color="#00e000" face="DejaVu Sans Condensed Bold">|g;
    $new_label =~ s|\x02|</font>|g;
    $new_label =~ s|\x03|<font color="#ff8080" face="DejaVu Sans Condensed Italic">|g;
    $new_label =~ s|\x04|</font>|g;

  } else {

    $new_label = wrap('', '', $label);

  }

  print "${id}[label=<$new_label>]\n";
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
