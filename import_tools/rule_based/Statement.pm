package Statement;

use Moose;


has 'parameters' => ( isa => 'ArrayRef[Parameter]', is => 'rw', default => sub {[]} );

has 'full_name' => ( isa => 'Str', is => 'rw' );
has 'label' => ( isa => 'Str', is => 'rw' );
has 'literature_references' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub {[]} );

has 'body' => ( isa => 'Str', is => 'rw' );



1;
