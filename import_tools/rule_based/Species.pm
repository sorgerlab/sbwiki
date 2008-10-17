package Species;

use Moose;


has 'initial_conditions' => ( isa => 'ArrayRef[Parameter]', is => 'rw', default => sub {[]} );
has 'contained_in' => ( isa => 'ArrayRef[Compartment]', is => 'rw', default => sub {[]} );

has 'full_name' => ( isa => 'Str', is => 'rw' );
has 'label' => ( isa => 'Str', is => 'rw' );
has 'synonyms' => ( isa => 'ArrayRef[Str]', is => 'rw' );
has 'literature_references' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub {[]} );

has 'doc' => ( isa => 'Str', is => 'rw' );



1;
