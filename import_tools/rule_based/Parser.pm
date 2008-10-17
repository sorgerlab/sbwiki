package Parser;

use Moose::Role;


requires 'parse_model';


sub die
{
  my ($self, @args) = @_;
  die $self->meta->name, ': ', @args, "\n";
}



1;
