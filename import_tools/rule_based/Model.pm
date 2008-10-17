package Model;

use Moose;


has 'interactions' => ( isa => 'ArrayRef[Statement]', is => 'rw', default => sub {[]} );
has 'parameters' => ( isa => 'ArrayRef[Parameter]', is => 'rw', default => sub {[]} );
has 'compartments' => ( isa => 'ArrayRef[Compartment]', is => 'rw', default => sub {[]} );
has 'species' => ( isa => 'ArrayRef[Species]', is => 'rw', default => sub {[]} );

has 'software_framework' => ( isa => 'Str', is => 'rw' );
has 'literature_references' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub {[]} );



1;
