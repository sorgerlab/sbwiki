package Parser_littleb;

use Moose;
use Moose::Autobox;
use IO::All;
use Regexp::Common;
use Data::SExpression;

use Model;
use Species;
use Statement;



with 'Parser';


has 'content' => (isa => 'Str', is => 'rw' );
has 'model' => ( isa => 'Model', is => 'rw' );


sub parse_model
{
  my ($self, $filename) = @_;

  $self->content( io($filename)->all );

  my $model = Model->new({ software_framework => 'littleb' });
  $self->model($model);

  $DB::single=1;
  $self->parse_species;
  print "\n";
  $self->parse_statements;
  1;
}


sub parse_species
{
  my ($self) = @_;

  my $ds = Data::SExpression->new({use_symbol_class => 1});
  foreach my $defmonomer ( $self->content =~ /$RE{balanced}{-keep=>1}/gs )
  {
    # D::SExp can't handle Aneil's "special" syntax, but defmonomer
    # statements seem to have normal sexp syntax
    $defmonomer =~ /defmonomer/ or next;

    my $data = $ds->read($defmonomer);

    my ($label, $doc, @sites) = splice(@$data, 1); # skip first symbol, 'defmonomer'
    my $compartment;
    if ( ref $label eq 'ARRAY' ) # if this is a list, it holds name and compartment
    {
      $compartment = $label->[1];
      $label = $label->[0];
    }
    # FIXME deal with sites

    print "species: $label\n";
    my $species = Species->new({ label => "$label", doc => $doc });
    $self->model->species->push($species);
  }
}


sub parse_statements
{
  my ($self) = @_;

  my $content_tmp = $self->content; # \G trick doesn't work without a local copy
  while ( $content_tmp =~ /\G.*?\\wikidoc{(.*?)}\n(.*?)(?:(?=\\wikidoc)|$)/gs )
  {
    my ($label, $body) = ($1, $2);

    print "statement: $label\n";
    my $stmt = Statement->new({ label => $label, body => $body });
    $self->model->interactions->push($stmt);

    $body =~ s/;.*$//gm;
    my @lines = ($body =~ /($RE{balanced}{-parens=>'()'})/g);
    foreach my $line ( @lines )
    {
      $self->parse_line($line);
    }
  }
}


sub parse_line
{
  my ($self, $line) = @_;
}



1;
