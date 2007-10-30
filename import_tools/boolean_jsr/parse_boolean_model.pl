#! /usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;

$| = 1;

my $infile = shift(@ARGV);
my $outdir = shift(@ARGV);
my ($uidfile);
my $result = GetOptions(
  "uidfile=s" => \$uidfile,
);
if (!defined($infile) or !defined($outdir) or !$result)
{
  die "usage: ./parse_model.pl infile outdir [--uidfile=uids.ini]\n";
}


# The number is how many rate constants it eats.
my %processes = ("<-->"  => 2,
		 "-->"   => 1,
		 "<-t->" => 2,
		 "=="    => 0 );
my %molecule_types = ('K' => 'protein kinase activity',
                      'A' => 'protein binding, bridging',
                      'G' => 'GTPase activity',
                      'P' => 'phosphoprotein phosphatase activity',
                      'T' => 'transcription regulator activity',
                      'R' => 'receptor activity',
                      ''  => '');
my $model_uid;
my %reactions; # Should point to ID number, which should maintain order.
my @reactions; # Should maintain order.
my @reactions_uids;
my %kinetics;
my %species; # Should point to ID number, maintaining order.
my @species; # Should maintain order.
my @species_uids;
my %facts;
my %wikifacts;
my %equivalences;
my %skip_reactions;
my %uid_counts = (SP => 0, RX => 0, MD => 0);


open(IN, "$infile") or die "Can't read $infile";
my $i = 0; # reaction counter;
my $j = 0; # species counter;


if (defined $uidfile)
{
  push @species_uids,   undef; # 1-based indexing
  push @reactions_uids, undef;

  my $line_number = 1;
  open(UIDFILE, "<$uidfile") or die("Couldn't open $uidfile: $!\n");
  while (my $uid = <UIDFILE>)
  {
    chomp $uid;
    if (my ($type) = $uid =~ /^([A-Z]{2})-[A-Z]+-\d+-?/)
    {
      exists $uid_counts{$type} or die("Error in $uidfile line $line_number: bad type, must be one of: ".
                                         join(',',keys(%uid_counts))."\n");
      $uid_counts{$type}++;
      push @species_uids,   $uid if $type eq 'SP';
      push @reactions_uids, $uid if $type eq 'RX';
      $model_uid = $uid          if $type eq 'MD';
    }
    $line_number++;
  }
  close(UIDFILE);
}


while(defined(my $line = <IN>)){
    chomp $line;
    my @tokens = split(/\|/, $line);
    @tokens = map { s/^\s*(.*?)\s*$/$1/; $_ } @tokens;

    my $entity_code = shift @tokens;

    if ($entity_code eq 'S')
    {
      # species
      my ($id, $code_name, $name, $full_name, $type) = map(escape_html($_), @tokens);
      $species{$code_name} = {id=>$id,name=>$name,full_name=>$full_name,type=>$type,logical_type=>'intermediate'};
      $species[$id] = $code_name;
    }
    elsif ($entity_code eq 'R')
    {
      # rule
      my ($id, $equation, $timescale, $description) = map(escape_html($_), @tokens);
      $reactions{$equation} = {id=>$id,timescale=>$timescale,description=>$description};
      $reactions[$id] = $equation;
    }
    else
    {
      warn("unknown entity code '$entity_code'\n");
    }

=pod

    if ($line =~ /^\s*%/){
        $i++;
        chomp $line;
	$reactions{$line} = $i;
#	push @reactions, $line;
	$reactions[$i] = $line;

	$reactions[$i] =~ s/^\s*%\s*//;
	$reactions[$i] =~ s/\s*$//;
	$line = $reactions[$i];
	$kinetics{$line} = <IN>;
	my @line = split(' ', $line);
	foreach my $s (@line){
	    if ($s ne "0" && $s ne "+" && $s ne "%" && !(defined($species{$s})) && !(defined($processes{$s}))){
		$j++;
		$species[$j] = $s;
		$species{$s} = $j;
	    }
	}
	@tokens = &tokenize_comment_line($line, \%processes, $i, $kinetics{$line});
    }

    # A token is an array conatinaing reactants, process, product, reaction number, and kinetics.
    if (&check_reaction_for_enzyme(\@tokens)){
	&parse_catalysis(\@tokens, \%facts, \%wikifacts);
    }
    else {
	foreach my $token (@tokens){
	    &parse_reaction_token($token, \%facts, \@reactions, \%wikifacts, \%equivalences, \%skip_reactions);
	}
    }

=cut

}
close IN;


if (defined $uidfile)
{
  unless ($uid_counts{SP} >= @species-1 and  $uid_counts{RX} >= @reactions-1 and $uid_counts{MD} >= 1)
  {
    print "You must provide the following numbers of UIDs for the given types:\n";
    printf "  species:   %4d  (I read %d)\n", scalar(@species)-1,   $uid_counts{SP}; # -1 since [0] is undef -- 1-based indexing!
    printf "  reactions: %4d  (I read %d)\n", scalar(@reactions)-1, $uid_counts{RX};
    printf "  models:    %4d  (I read %d)\n", 1,                    $uid_counts{MD};
    exit(1);
  }
  if ($uid_counts{MD} > 1)
  {
    print "You must only provide one model (MD) UID.  I read $uid_counts{MD}.\n";
    exit(1);
  }
}
else
{
  # generate fake uids
  @species_uids = map { "SP-x-n-".$_ } @species[1..$#species];
  unshift(@species_uids, undef);
  @reactions_uids = map { "RX-x-n-r".$_->{id} } @reactions{@reactions[1..$#reactions]};
  unshift(@reactions_uids, undef);
  $model_uid = "MD-x-n-$outdir";
}


fixup_species_types();

write_main_page();
#write_allspecies_page();
#write_allreaction_page();
write_species_pages();
write_reaction_pages();
open(XML, ">>$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";
print XML "</mediawiki>\n";
close XML;
# END OF MAIN STRUCTURE
################################################


sub fixup_species_types
{

  foreach my $rid (1..$#reactions){

    my $equation = $reactions[$rid];

    my ($inputs, $outputs) = parse_equation($equation, strip_bang => 1);
    if (!@$inputs)
    {
      $species{$outputs->[0]}{logical_type} = 'input';
    }
    if (!@$outputs)
    {
      # assumes just one input (any others will be ignored)
      $species{$inputs->[0]}{logical_type} = 'output';
    }

  }

}


#############################################################################
sub tokenize_comment_line(){
    # Goal: Split multireaction line to a number of 'tokens' of the form 
    # REACTANT PROCESS PRODUCT
    my $line = shift;
    my $processes = shift;
    my $rxn_id = shift;
    my $kinetics = shift;
    chomp $kinetics;
    $kinetics =~ s/%.*$//;
    my @kinetics = split(";", $kinetics);

    $line =~ s/^\s*%//;
    my @pretokenlist;
    my $i = 0;
    my $state = 0;
    my @line = split(' ', $line);
    my $element = "";
    foreach my $i (0..$#line){
	if (!(defined($processes->{$line[$i]}))){
	    $element .= " $line[$i]";
	}
	else {
	    push @pretokenlist, $element;
	    push @pretokenlist, $line[$i];
	    $element = "";
	}
	if ($i == $#line){
	    push @pretokenlist, $element;
	}
    }

    my @tokenlist;
    foreach my $i (0..$#pretokenlist){
	if (defined($processes->{$pretokenlist[$i]})){
	    $tokenlist[$#tokenlist+1] = [];
	    push @{$tokenlist[$#tokenlist]}, $pretokenlist[$i-1];
	    push @{$tokenlist[$#tokenlist]}, $pretokenlist[$i];
	    push @{$tokenlist[$#tokenlist]}, $pretokenlist[$i+1];
	    push @{$tokenlist[$#tokenlist]}, $rxn_id;
	    my $p = 0;
	    while($p < $processes{$pretokenlist[$i]}){
		push @{$tokenlist[$#tokenlist]}, shift @kinetics;
		$p++;
	    }
#	    print join(' ', @{$tokenlist[$#tokenlist]}) . "\n";
	      
	}
    }
    return @tokenlist;
}
#############################################################################
sub parse_reaction_token(){
    my $reaction = shift;
    my $facts = shift;
    my $reactions = shift;
    my $wikifacts = shift;
    my $equivalences = shift;
    my $skip = shift;
    my %reactions;
    my $reactant = $reaction->[0];
    my $process = $reaction->[1];
    my $product = $reaction->[2];
    my $r_id = $reaction->[3];

    # Parse reactants
    $reactant =~ s/\s//g;
    my @reactants = split('\+', $reactant);
    my @htmlr;
    my @wikir;
    foreach my $r (0..$#reactants){
	if ($reactants[$r] ne "0"){
	    $htmlr[$r] = "<A HREF=\"" . escape_url($species_uids[$species{$reactants[$r]}]) . ".html\">$reactants[$r]</A>";
	    $wikir[$r] = "$outdir/$reactants[$r]|$reactants[$r]";
	}
    }

    # Parse products
    $product =~ s/\s//g;
    my @products = split('\+', $product);
    my @htmlp;
    my @wikip;
    foreach my $p (0..$#products){
	if ($products[$p] ne "0"){
	    $htmlp[$p] = "<A HREF=\"" . escape_url($species_uids[$species{$products[$p]}]) . ".html\">$products[$p]</A>";
	    $wikip[$p] = "$outdir/$products[$p]|$products[$p]";
	}
    }


#    print "$reactant $process $product\n";
#    print scalar(@reactants) . $process . scalar(@products) . "\n";

    # Parse each process into facts.
    
    ########################################################
    # --> is a conversion.
    if ($process eq "-->"){
	my @rc1 = split('=', $reaction->[4]);
	if ($reactants[0] eq "0" && scalar(@reactants) == 1 && scalar(@products) == 1) {
	    &synthesize(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    $skip->{$r_id} = 1;
	}
	elsif ($products[0] eq "0" && scalar(@reactants) == 1 && scalar(@products) == 1) {
	    &degrade(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    $skip->{$r_id} = 1;
	}
	elsif (scalar(@products) == 1 && scalar(@reactants) == 1) {
	    &iconvert(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	}
	else { die "Don't understand $reactions"; }
    }
    ########################################################
    elsif ($process eq "<-->"){
	my @rc1 = split('=', $reaction->[4]);
	my @rc2 = split('=', $reaction->[5]);
	# Reactant facts.
	if ($reactants[0] eq "0" && scalar(@reactants) == 1 && scalar(@products) == 1) {
	    &synthesize(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    &degrade(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	    $skip->{$r_id} = 1;
	    
	}
	elsif ($products[0] eq "0" && scalar(@reactants) == 1 && scalar(@products) == 1) {
	    &degrade(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    &synthesize(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	    $skip->{$r_id} = 1;
	    
	}
	elsif ((scalar(@reactants) == 1) && (scalar(@products) == 2)) {
	    &dissociate(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    &associate(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	}
	elsif ((scalar(@reactants) == 2) && (scalar(@products) == 1)) {
	    &associate(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    &dissociate(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	}	    
	elsif ((scalar(@reactants) == 1) && (scalar(@products) == 1)) {
	    &rconvert(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
	    &rconvert(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	}
	else {die "Don't understand $reaction.";}
    }
    ########################################################
    elsif ($process eq "<-t->"){
	my @rc1 = split('=', $reaction->[4]);
	my @rc2 = split('=', $reaction->[5]);
	if ((scalar(@reactants) == 1) && (scalar(@products) == 1)) {
	    &translocate(\@reactants, \@products, $facts, $wikifacts, "$rc1[1]", \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions);
    	    &translocate(\@products, \@reactants, $facts, $wikifacts, "$rc2[1]", \@htmlp, \@htmlr, \@wikip, \@wikir, $reaction->[3], \@reactions);
	}
	else {die "Don't understand $reaction.";}
    }
    ########################################################
    elsif ($process eq "=="){
	if ((scalar(@reactants) == 1) && (scalar(@products) == 1)) {
	    &equivalence(\@reactants, \@products, $facts, $wikifacts, \@htmlr, \@htmlp, \@wikir, \@wikip, $reaction->[3], \@reactions, $equivalences);
	}
	else {die "Don't understand $reaction.";}
    }
    ########################################################
    else {die "What's this process: $process";}
}
#############################################################################
sub write_main_page {
    if(! -d "$outdir"){
	`mkdir $outdir`;
	`cp $infile $outdir/$infile`;
    }

    my $nr = (scalar(@reactions) - 1) - scalar(keys %skip_reactions);
    my $ns = scalar(@species) - 1 - scalar(keys %equivalences);

#    open(OUT, ">$outdir/index.html") or die "Can't write $outdir/index.html";
#    print OUT "<head><title>$model_uid Model</title>\n";
#    print OUT "</head><body>\n";
#    print OUT "<h1>$model_uid Model</h1>\n";
#    print OUT "<BR><HR><BR>\n";
#    print OUT "This model website was autogenned from <A HREF=\"rxn_list2.txt\">this source</A>.<BR><HR>\n";
#    print OUT "This model contains <A HREF=\"species.html\">" . $ns . " unique species</A>.<BR>\n"; 
#    print OUT "This model contains <A HREF=\"reactions.html\">" . $nr . " reactions</A>, plus <A HREF=\"synthdeg.html\">". scalar(keys %skip_reactions) ." synthesis and degradation reactions</A>.<BR><HR>\n"; 
#    print OUT "If you approve of this model, download the file <A HREF=\"$outdir.xml\">$outdir.xml</A> now, and upload it at <A HREF=\"http://ome-sorger7.mit.edu/~jmuhlich/mwtest/index.php/Special:Import\">http://ome-sorger7.mit.edu/~jmuhlich/mwtest/index.php/Special:Import</A>.<BR><HR>\n";
#    print OUT "</body></html>\n";
#    close OUT;


    open(XML, ">$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";
    print XML "<mediawiki xmlns=\"http://www.mediawiki.org/xml/export-0.3/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.mediawiki.org/xml/export-0.3/ http://www.mediawiki.org/xml/export-0.3.xsd\" version=\"0.3\" xml:lang=\"en\">\n";
    print XML "<page>\n";
    print XML "<title>$model_uid</title>\n";
    print XML "<revision><timestamp>".`date -u  +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    print XML "{{Logical_model\n";
#    print XML "|name=$outdir/\n";
    print XML "|organism=\n";
    print XML "|cell type=\n";
    print XML "|cell processes=\n";
    print XML "|modeler=\n";
    print XML "|references=\n";
    print XML "}}\n\n";
    print XML "== Model Contents == \n\n";
#    print XML "This model describes [[$model_uid/Species|$ns unique species]].\n\n";
#    print XML "This model describes [[$model_uid/Reactions|$nr reactions]], plus [[$model_uid/Synthesis and Degradation|". scalar(keys %skip_reactions) ." synthesis and degradation reactions]].\n\n";
    foreach my $species (1..$#species){
	print XML "[[has species::$species_uids[$species]| ]]\n";
    }
    print XML "</text></revision></page>\n";
    close XML;

}
#############################################################################
sub write_allspecies_page {
    open(OUT, ">$outdir/species.html") or die "Can't write $outdir/species.html";
    print OUT "<head><title>$model_uid Model</title>\n";
    print OUT "</head><body>\n";
    print OUT "<h1>$model_uid Model - Species Home</h1>\n";
    print OUT "<BR><HR><BR>\n";
    
    my %reverse_equivalences;
    foreach my $eq (keys %equivalences){
	$reverse_equivalences{$equivalences{$eq}} = $eq;
    }

#    foreach my $species (sort keys %species){
    foreach my $species (1..$#species){
	$species = $species[$species];
	if(defined $reverse_equivalences{$species}){
	    print OUT "<A HREF=\"",escape_url($species_uids[$species{$species}]),".html\">$species (aka $reverse_equivalences{$species})</A><BR>\n";
	}
	elsif(!defined $equivalences{$species}){
	    print OUT "<A HREF=\"",escape_url($species_uids[$species{$species}]),".html\">$species</A><BR>\n";
	}
    }
    print OUT "<HR>Back to <A HREF=\"index.html\">model home</A>.<BR>\n";
    print OUT "<HR></body></html>\n";
    close OUT;

    open(XML, ">>$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";
    print XML "<page>\n";
    print XML "<title>$model_uid/Species</title>\n";
    print XML "<revision><timestamp>".`date +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    print XML "This is the list of unique species in the model [[$model_uid]].\n\n";

    foreach my $species_number (1..$#species){
        my $species = $species[$species_number];
	if(defined $reverse_equivalences{$species}){
	    print XML "# [[has species::$species_uids[$species_number]|$species (aka $reverse_equivalences{$species})]]\n";
	}
	elsif(!defined $equivalences{$species}){
	    print XML "# [[has species::$species_uids[$species_number]|$species]]\n";
	}
    }
    print XML "</text></revision></page>\n";
    close XML;
}
#############################################################################
sub write_allreaction_page {
    open(OUT, ">$outdir/reactions.html") or die "Can't write $outdir/reactions.html";
    print OUT "<head><title>$model_uid Model</title>\n";
    print OUT "</head><body>\n";
    print OUT "<h1>$model_uid Model - Reactions Home</h1>\n";
    print OUT "<BR><HR><BR>\n";
    
    foreach my $rid (1..$#reactions){
	if (!defined $skip_reactions{$rid}){
	    print OUT "<A HREF=\"",escape_url($reactions_uids[$rid]),".html\">$reactions[$rid]</A><BR>";
	}
    }
    print OUT "<HR>Back to <A HREF=\"index.html\">model home</A>.<BR>\n";
    print OUT "<HR></body></html>\n";
    close OUT;

    open(OUT, ">$outdir/synthdeg.html") or die "Can't write $outdir/synthdeg.html";
    print OUT "<head><title>$model_uid Model</title>\n";
    print OUT "</head><body>\n";
    print OUT "<h1>$model_uid Model - Synthesis and Degradation Home</h1>\n";
    print OUT "<BR><HR><BR>\n";
    
    foreach my $rid (1..$#reactions){
	if (defined $skip_reactions{$rid}){
	    print OUT "<A HREF=\"",escape_url($reactions_uids[$rid]),".html\">$reactions[$rid]</A><BR>";
	}
    }
    print OUT "<HR>Back to <A HREF=\"index.html\">model home</A>.<BR>\n";
    print OUT "<HR></body></html>\n";
    close OUT;


    open(XML, ">>$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";
    print XML "<page>\n";
    print XML "<title>$model_uid/Reactions</title>\n";
    print XML "<revision><timestamp>".`date +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    print XML "This is the list of mass-action reactions in the model [[$model_uid]].\n\n";
    foreach my $r (1..$#reactions){
	my $rxn = $reactions[$r];
	if (!defined $skip_reactions{$r}){
	    $rxn =~ s/</\&lt\;/g;
	    print XML "# [[$reactions_uids[$r]|$rxn]]\n";
	}
    }
    print XML "</text></revision></page>\n";
    print XML "<page>\n";
    print XML "<title>$model_uid/Synthesis and Degradation</title>\n";
    print XML "<revision><timestamp>".`date +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    print XML "This is the list of synthesis and degradation reactions in the model [[$model_uid/]].\n\n";
    foreach my $r (1..$#reactions){
	
	my $rxn = $reactions[$r];
	if (defined $skip_reactions{$r}){
	    $rxn =~ s/</\&lt\;/g;
	    print XML "# [[$reactions_uids[$r]|$rxn]]\n";
	}
    }
    print XML "</text></revision></page>\n";    close XML;


}
#############################################################################
sub write_species_pages {

  open(XML, ">>$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";

  foreach my $s (1..$#species){
    my $code_name = $species[$s];
    my %sd = %{$species{$code_name}}; # species data

    my @reactions_wikitext;
    foreach my $r (1..$#reactions)
    {
      my $equation = $reactions[$r];
      (my $equation_escaped = $equation) =~ s/>/&gt;/g;
      my %rd = %{$reactions{$equation}};

      # output annotated rule text for all rules in which this species participates
      my ($inputs, $outputs) = parse_equation($equation);
      if ( (my $match) = grep { $_ =~ /^!?\Q$code_name\E$/ } (@$inputs, @$outputs) )
      {
        my $output = $outputs->[0]; # assume one output
        my $is_output = $output && $output eq $code_name;

        # build annotated input species list
        my @inputs_wikitext;
        foreach my $input (@$inputs)
        {
          my $input_activity = $input =~ s/^!// ? 'inactive' : 'active';
          my $input_relation = $is_output ? 'determined by::' : '';
          my $input_uid = $species_uids[$species{$input}{id}];
          push @inputs_wikitext, "$input_activity " .
            ($input eq $code_name ? "'''$code_name'''" : "[[${input_relation}${input_uid}]]");
        }

        my $output_relation = $is_output ? '' : 'determines activity of::';
        my $output_uid = $species_uids[$species{$output}{id}];
        my $output_wikitext = $is_output ? "'''$code_name'''" : "[[${output_relation}${output_uid}]]";

        my $self_activity = $match =~ /^!/ ? 'inactive' : 'active';
        my $rule_relation = $is_output ? 'activated by::' : "$self_activity drives::";

        my $drive_text = @$inputs == 1 ? 'drives' : 'drive';

        push @reactions_wikitext, join(" AND ", @inputs_wikitext) . " $drive_text the activity of " . $output_wikitext;
        push @reactions_wikitext, ": [[${rule_relation}$reactions_uids[$rd{id}]|[$rd{id}]]]: " . $equation_escaped;
      }
    }

    print XML "<page>\n";
    print XML "<title>$species_uids[$s]</title>\n";
    print XML "<revision><timestamp>".`date +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    # TODO: logical_species_type based on rules; references by parsing description
    print XML <<SPECIES;
{{Logical_species
|name=$sd{name}
|synonyms=
|full_name=$sd{full_name}
|uniprot=
|molecule_type=$molecule_types{$sd{type}}
|logical_species_type=$sd{logical_type}
|localization=
|initial_value=
|references=
}}
SPECIES

    print XML "== Rules == \n\n";
    print XML join("\n\n", @reactions_wikitext), "\n\n";

    print XML "</text></revision></page>\n";
  }

  close XML;

}
#############################################################################
sub write_reaction_pages {

  open(XML, ">>$outdir/$outdir.xml") or die "Can't write $outdir/$outdir.xml";

  foreach my $rid (1..$#reactions){
    my $equation = $reactions[$rid];
    my %rd = %{$reactions{$equation}}; # reaction data

    (my $equation_escaped = $equation) =~ s/>/&gt;/g;

    my ($inputs, $outputs) = parse_equation($equation, strip_bang=>1);
    my @inputs  = @$inputs;
    my @outputs = @$outputs;

    my @inputs_wikitext;
    foreach my $input_name (@inputs)
    {
      if ( !exists $species{$input_name} )
      {
        warn("undefined input species '$input_name' in rule $rd{id}: $equation\n");
        next;
      }
      my $species_uid = $species_uids[$species{$input_name}{id}];
      my $species_name = $species{$input_name}{name};
      push @inputs_wikitext, "[[driven by activity of::$species_uid]]";
    }
    my @outputs_wikitext;
    foreach my $output_name (@outputs)
    {
      if ( !exists $species{$output_name} )
      {
        warn("undefined ouput species '$output_name' in rule $rd{id}: $equation\n");
        next;
      }
      my $species_uid = $species_uids[$species{$output_name}{id}];
      push @outputs_wikitext, "[[leads to activation of::$species_uid]]";
    }

    print XML "<page>\n";
    print XML "<title>$reactions_uids[$rid]</title>\n";
    print XML "<revision><timestamp>".`date +%Y-%m-%dT%H:%M:%SZ` ."</timestamp><text xml:space=\"preserve\">\n";
    # TODO: parse references from description
    print XML <<RULE;
{{Logical_rule
|logical_equation=$equation_escaped
|name=r$rd{id}
|parameters=&amp;tau; = $rd{timescale}
|references=
}}
$rd{description}
RULE

    print XML "== Participants ==\n";
    print XML "Inputs:\n", join(",\n", @inputs_wikitext), "\n\n";
    print XML "Outputs:\n", join(",\n", @outputs_wikitext), "\n\n";

    print XML "</text></revision></page>\n";
  }

  close XML;
}
#############################################################################

###########################
# A set of functions for specific cases.
sub check_reaction_for_enzyme(){
    my $tokens = shift;
    if (scalar(@{$tokens}) != 2) {
	return 0;
    }
    my @reactants1 = split('\+', $tokens->[0]->[0]);
    my @reactants2 = split('\+', $tokens->[1]->[0]);
    my $process1 = $tokens->[0]->[1];
    my $process2 = $tokens->[1]->[1];
    my @products1 = split('\+',$tokens->[0]->[2]);
    my @products2 = split('\+',$tokens->[1]->[2]);
    if (($process1 ne "<-->") || ($process2 ne "-->")) {return 0;} 
    if ((scalar(@reactants1) != 2) || (scalar(@reactants2) != 1) || (scalar(@products2) != 2)){return 0;}
    my $match = 0;
    foreach my $r (@reactants1){
	foreach my $p (@products2){
	    if ($r eq $p) {$match = 1;}
	}
    }
    return $match;
}

sub parse_catalysis(){
    my $tokens = shift;
    my $facts = shift;
    my $wikifacts = shift;

    $tokens->[0]->[0] =~ s/\s//g;
    my @reactants = split('\+', $tokens->[0]->[0]);
    $tokens->[1]->[0] =~ s/\s//g;
    my $intermediate = $tokens->[1]->[0];
    $tokens->[1]->[2] =~ s/\s//g;
    my @products = split('\+',$tokens->[1]->[2]);
    my $substrate;  my $product; my $enzyme;
    if ($reactants[0] eq $products[0]) {
	$enzyme = $reactants[0];  $substrate = $reactants[1]; $product = $products[1];
    }
    elsif ($reactants[0] eq $products[1]) {
	$enzyme = $reactants[0];  $substrate = $reactants[1]; $product = $products[0];
    }
    elsif ($reactants[1] eq $products[0]) {
	$enzyme = $reactants[1];  $substrate = $reactants[0]; $product = $products[1];
    }
    elsif ($reactants[1] eq $products[1]) {
	$enzyme = $reactants[1];  $substrate = $reactants[0]; $product = $products[0];
    }
    my $henzyme = "<A HREF=\"" . escape_url($species_uids[$species{$enzyme}]) . ".html\">$enzyme</A>";  
    my $wenzyme = "$species_uids[$species{$enzyme}]|$enzyme";
    my $hsubstrate = "<A HREF=\"" . escape_url($species_uids[$species{$substrate}]) . ".html\">$substrate</A>";  
    my $wsubstrate = "$species_uids[$species{$substrate}]|$substrate";
    my $hproduct = "<A HREF=\"" . escape_url($species_uids[$species{$product}]) . ".html\">$product</A>";  
    my $wproduct = "$species_uids[$species{$product}]|$product";
    my $hintermediate = "<A HREF=\"" . escape_url($species_uids[$species{$intermediate}]) . ".html\">$intermediate</A>";  
    my $wintermediate = "$species_uids[$species{$intermediate}]|$intermediate";
    my ($fact, $wfact);

    $fact = "$enzyme catalyzes the conversion of $hsubstrate to $hproduct via the intermediate complex $hintermediate.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1])</I><BR>\n";
    $wfact = "$enzyme catalyzes the conversion of [[has substrate::$wsubstrate]] to [[makes product::$wproduct]] via the intermediate complex [[part of complex::$wintermediate]]\n\n";
    $wfact .= ": ''[$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1]''\n\n";
    if(!defined($facts->{$enzyme})) { 
	$facts->{$enzyme} = []; 
	$wikifacts->{$enzyme} = []; 
    }
    push @{$facts->{$enzyme}}, $fact;  push @{$wikifacts->{$enzyme}}, $wfact;

    $fact = "$substrate is catalytically converted to $hproduct by the enzyme $henzyme via the intermediate complex $hintermediate.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1])</I><BR>\n";
    $wfact = "$substrate is catalytically converted to [[converts to::$wproduct]] by the enzyme [[substrate of::$wenzyme]] via the intermediate complex [[part of complex::$wintermediate]]\n\n";
    $wfact .= ": ''[$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1]''\n\n";
    if(!defined($facts->{$substrate})) { 
	$facts->{$substrate} = []; 
	$wikifacts->{$substrate} = []; 
    }
    push @{$facts->{$substrate}}, $fact;  push @{$wikifacts->{$substrate}}, $wfact;

    $fact = "$product is catalytically converted from $hsubstrate by the enzyme $henzyme via the intermediate complex $hintermediate.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1])</I><BR>\n";
    $wfact = "$product is catalytically converted from [[converted from::$wsubstrate]] by the enzyme [[product of::$wenzyme]] via the intermediate complex [[$wintermediate]]\n\n";
    $wfact .= ": ''[$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1]''\n\n";
    if(!defined($facts->{$product})) { 
	$facts->{$product} = []; 
	$wikifacts->{$product} = []; 
    }
    push @{$facts->{$product}}, $fact;  push @{$wikifacts->{$product}}, $wfact;

    $fact = "$intermediate is an intermediate complex made from the enzyme $henzyme and its substrate $hsubstrate in the process of making product $hproduct.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1])</I><BR>\n";
    $wfact = "$intermediate is an intermediate complex made from the enzyme [[has component::$wenzyme]] and its substrate [[has component::$wsubstrate]] in the process of making product [[$wproduct]]\n\n";
    $wfact .= ": ''[$tokens->[0]->[3]]: $reactants[0] + $reactants[1] <--> $intermediate --> $products[0] + $products[1]''\n\n";
    if(!defined($facts->{$intermediate})) { 
	$facts->{$intermediate} = []; 
	$wikifacts->{$intermediate} = []; 
    }
    push @{$facts->{$intermediate}}, $fact;  push @{$wikifacts->{$intermediate}}, $wfact;
    
}

sub associate(){
    my $reactants = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;

    my $fact =  "$reactants->[0] and $htmlr->[1] associate to form $htmlp->[0] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact =  "$reactants->[0] and [[binds to::$wikir->[1]]] associate to form [[part of complex::$wikip->[0]]] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactants->[0]})) { 
	$facts->{$reactants->[0]} = []; 
	$wikifacts->{$reactants->[0]} = []; 
    }
    push @{$facts->{$reactants->[0]}}, $fact;  push @{$wikifacts->{$reactants->[0]}}, $wfact;

    $fact =  "$reactants->[1] and $htmlr->[0] associate to form $htmlp->[0] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";

    $wfact =  "$reactants->[1] and [[binds to::$wikir->[0]]] associate to form [[part of complex::$wikip->[0]]] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactants->[1]})) { 
	$facts->{$reactants->[1]} = []; 
	$wikifacts->{$reactants->[1]} = []; 
    }
    push @{$facts->{$reactants->[1]}}, $fact;  push @{$wikifacts->{$reactants->[1]}}, $wfact;

    $fact =  "$product->[0] is formed by the association of $htmlr->[0] and $htmlr->[1] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact =  "$product->[0] is formed by the association of [[$wikir->[0]]] and [[$wikir->[1]]] with rate constant $rc MPC<sup>-1</sup>sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;

}

sub dissociate(){
    my $reactant = shift;    my $products = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;

    my $fact =  "$reactant->[0] dissociates to $htmlp->[0] and $htmlp->[1] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact =  "$reactant->[0] dissociates to [[has component::$wikip->[0]]] and [[has component::$wikip->[1]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

    $fact =  "$products->[0] is formed along with $htmlp->[1] by the dissociation of $htmlr->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact =  "$products->[0] is formed along with [[$wikip->[1]]] by the dissociation of [[$wikir->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$products->[0]})) { 
	$facts->{$products->[0]} = []; 
	$wikifacts->{$products->[0]} = []; 
    }
    push @{$facts->{$products->[0]}}, $fact;  push @{$wikifacts->{$products->[0]}}, $wfact;

    $fact =  "$products->[1] is formed along with $htmlp->[0] by the dissociation of $htmlr->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact =  "$products->[1] is formed along with [[$wikip->[0]]] by the dissociation of [[$wikir->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$products->[1]})) { 
	$facts->{$products->[1]} = []; 
	$wikifacts->{$products->[1]} = []; 
    }
    push @{$facts->{$products->[1]}}, $fact;  push @{$wikifacts->{$products->[1]}}, $wfact;
}

sub synthesize(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    
    my $fact = "$product->[0] is synthesized with rate constant $rc MPC sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$product->[0] is synthesized with rate constant $rc MPC sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;

}

sub degrade(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    
    my $fact = "$reactant->[0] is degraded with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$reactant->[0] is degraded with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

}

sub rconvert(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    
    my $fact = "$reactant->[0] is reversibly converted to $htmlp->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$reactant->[0] is reversibly converted to [[converts to::$wikip->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

    $fact = "$product->[0] is reversibly converted from $htmlr->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact = "$product->[0] is reversibly converted from [[converted from::$wikir->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;
}

sub translocate(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    
    my $fact = "$reactant->[0] becomes $htmlp->[0] via translocation, with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$reactant->[0] becomes [[translocates to::$wikip->[0]]] via translocation, with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

    $fact = "$product->[0] is made via the translocation of $htmlr->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact = "$product->[0] is made via the translocation of [[translocated from::$wikir->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;
}

sub iconvert(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;    my $rc = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    
    my $fact = "$reactant->[0] is irreversibly converted to $htmlp->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$reactant->[0] is irreversibly converted to [[converts to::$wikip->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

    $fact = "$product->[0] is irreversibly converted from $htmlr->[0] with rate constant $rc sec<sup>-1</sup>.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact = "$product->[0] is irreversibly converted from [[converted from::$wikir->[0]]] with rate constant $rc sec<sup>-1</sup>.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;
}

sub equivalence(){
    my $reactant = shift;    my $product = shift;    my $facts = shift;    my $wikifacts = shift;
    my $htmlr = shift;    my $htmlp = shift;    my $wikir = shift;    my $wikip = shift;  my $r_id = shift;  my $reactions = shift;
    my $equivalences = shift;
    
    my $fact = "$reactant->[0] and $htmlp->[0] are equivalent.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    my $wfact = "$reactant->[0] and [[equivalent to::$wikip->[0]]] are equivalent.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$reactant->[0]})) { 
	$facts->{$reactant->[0]} = []; 
	$wikifacts->{$reactant->[0]} = []; 
    }
    push @{$facts->{$reactant->[0]}}, $fact;  push @{$wikifacts->{$reactant->[0]}}, $wfact;

    $fact = "$product->[0] and $htmlr->[0] are equivalent.\n";
    $fact .= "&nbsp&nbsp&nbsp&nbsp&nbsp<I>([$r_id]: " . $reactions->[$r_id]. ")</I><BR>\n";
    $wfact = "$product->[0] and [[equivalent to::$wikir->[0]]] are equivalent.\n\n";
    $wfact .= ": ''[$r_id]: $reactions->[$r_id]''\n\n";
    if(!defined($facts->{$product->[0]})) { 
	$facts->{$product->[0]} = []; 
	$wikifacts->{$product->[0]} = []; 
    }
    push @{$facts->{$product->[0]}}, $fact;  push @{$wikifacts->{$product->[0]}}, $wfact;

    # Now i need to think about what to do, structurally, about
    # equivalence.  Give the reactant a page with exactly one inferred
    # fact.  Transfer all others, using the name product (aka
    # reactant).  But, I need to do it at the very end.
    if (defined $equivalences->{$reactant->[0]}){ die "$reactant->[0] equivalent to multiple other things?"}
    $equivalences->{$reactant->[0]} = $product->[0];

}



sub escape_url() {
  my $url = shift;

  $url =~ s/:/%3A/g;

  return $url;
}


sub escape_html {
  my $text = shift;

  $text =~ s/&/&amp;/g;

  return $text;
}


sub parse_equation
{
  my ($equation, %options) = @_;

  my ($lhs, $rhs) = split(/-->/, $equation);
  my @inputs  = grep { $_ ne '+' } split(' ', $lhs);
  my @outputs = grep { $_ ne '+' } split(' ', $rhs);

  @inputs = map { s/^!//; $_ } @inputs if $options{strip_bang};

  return (\@inputs, \@outputs);
}
