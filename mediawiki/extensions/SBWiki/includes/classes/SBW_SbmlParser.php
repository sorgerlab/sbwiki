<?php


class SBWSbmlReader {

  protected $model;


  public function SBWSbmlReader($content) {
    if ($content) {
      $this->readSbmlFromString($content);
    }
  }


  public function readSbmlFromString($content) {

    $xml = simplexml_load_string($content);
    $model = new SBWSbmlModel();

    foreach ( $xml->model->listOfSpecies->species as $species_elt ) {
      $species = new SBWSbmlSpecies((string) $species_elt['id']);
      $species->name                 = (string) $species_elt['name'];
      $species->initialConcentration = (float) $species_elt['initialConcentration'];
      $model->addSpecies($species);
    }

    $i = 1;
    foreach ( $xml->model->listOfReactions->reaction as $reaction_elt ) {
      $reaction = new SBWSbmlReaction((string) $reaction_elt['id']);
      $reaction->name         = (string) $reaction_elt['name'];
      $reaction->isReversible = $reaction_elt['reversible'] == 'true';
      foreach ( $reaction_elt->listOfReactants->speciesReference as $speciesref_elt ) {
        $reaction->addReactant($model->getSpecies((string) $speciesref_elt['species']));
      }
      foreach ( $reaction_elt->listOfProducts->speciesReference as $speciesref_elt ) {
        $reaction->addProduct($mode->getSpecies((string) $speciesref_elt['species']));
      }  
      $model->addReaction($reaction);
    }

    $this->model = $model;

  }


  function getModel() {
    return $this->model;
  }


}



class SBWSbmlModel {

  protected $species_set  = array();
  protected $reaction_set = array();


  public function addSpecies($species) {
    $this->species_set[$species->id] = $species;
  }


  public function addReaction($reaction) {
    $this->reaction_set[$reaction->id] = $reaction;
  }


  public function getSpecies($id) {
    return $this->species_set[$id];
  }


  public function getReaction($id) {
    return $this->reaction_set[$id];
  }


  public function getSpeciesIds() {
    return array_keys($this->species_set);
  }


  public function getReactionIds() {
    return array_keys($this->reaction_set);
  }


}



class SBWSbmlSpecies {
  
  public $id;
  public $name;
  public $initialConcentration;


  public function SBWSbmlSpecies($id) {
    if (!isset($id)) {
      trigger_error("No id specified", E_USER_ERROR);
    }
    $this->id = $id;
  }


}



class SBWSbmlReaction {
  
  public    $id;
  public    $name;
  public    $isReversible;
  protected $reactants    = array();
  protected $products     = array();


  public function SBWSbmlReaction($id) {
    if (!isset($id)) {
      trigger_error("No id specified", E_USER_ERROR);
    }
    $this->id = $id;
  }

  public function addReactant($species) {
    $this->reactants[] = $species;
  }

  public function addProduct($species) {
    $this->products[] = $species;
  }


  public function asText() {
    return
      implode(' + ', array_map(create_function('$s', 'return $s->name;'), $this->reactants)) .
      ($this->isReversible ? ' <--> ' : ' --> ') .
      implode(' + ', array_map(create_function('$s', 'return $s->name;'), $this->products))
      ;
  }


}



?>
