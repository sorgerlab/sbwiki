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
    $model = new SBWSbmlModel($xml->model['id']);
    $this->parseNotes($model, $xml->model);

    foreach ( $xml->model->listOfSpecies->species as $species_elt ) {
      $species = new SBWSbmlSpecies($species_elt['id']);
      $species->name = (string) $species_elt['name'];
      $this->parseNotes($species, $species_elt);
      $icParameter = new SBWSbmlParameter($species->getBestName() . '_0');
      $icParameter->value = (float) $species_elt['initialConcentration'];
      $icParameter->notes = "Initial concentration of " . $species->getBestName();
      $species->initialConcentration = $icParameter;
      $model->addParameter($icParameter);
      $model->addSpecies($species);
    }

    $i = 1;
    foreach ( $xml->model->listOfReactions->reaction as $reaction_elt ) {
      $reaction = new SBWSbmlReaction($reaction_elt['id']);
      $reaction->name         = (string) $reaction_elt['name'];
      $reaction->isReversible = $reaction_elt['reversible'] == 'true';
      $this->parseNotes($reaction, $reaction_elt);
      foreach ( $reaction_elt->listOfReactants->speciesReference as $speciesref_elt ) {
        $reaction->addReactant($model->getSpecies((string) $speciesref_elt['species']));
      }
      foreach ( $reaction_elt->listOfProducts->speciesReference as $speciesref_elt ) {
        $reaction->addProduct($model->getSpecies((string) $speciesref_elt['species']));
      }
      foreach ( $reaction_elt->kineticLaw->listOfParameters->parameter as $par_elt ) {
	$parameter = new SBWSbmlParameter($par_elt['id']);
	$parameter->name  = (string) $par_elt['name'];
	$parameter->value = (float) $par_elt['value'];
	$this->parseNotes($parameter, $par_elt);
	$model->addParameter($parameter);
	$reaction->addParameter($parameter);
      }
      $model->addReaction($reaction);
    }

    $this->model = $model;

  }


  function getModel() {
    return $this->model;
  }


  public function parseNotes($entity, $elt) {
    $notes = '';
    $body_elt = $elt->notes->body;
    if ($body_elt) {
      foreach ($body_elt->children() as $c_elt) {
	$notes .= $c_elt->asXML();
      }
    }
    if (strlen($notes)) $notes = '<html>'.$notes.'</html>'; # FIXME: replace with perl HTML::WikiConverter script
    $entity->notes = $notes;
  }

}



class SBWSbmlEntity {

  public $uid;
  public $id;
  public $name;
  public $notes;


  public function SBWSbmlEntity($id) {
    if (!isset($id)) {
      trigger_error("No id specified", E_USER_ERROR);
    }
    $this->id = (string) $id; // cast from likely SimpleXMLElement
  }


  /*
   Return name if set, otherwise id (xml id).
   */
  public function getBestName() {
    return strlen($this->name) ? $this->name : $this->id;
  }

}



class SBWSbmlModel extends SBWSbmlEntity {

  protected $species_set   = array();
  protected $reaction_set  = array();
  protected $parameter_set = array();


  public function addSpecies($species) {
    $this->species_set[$species->id] = $species;
  }


  public function addReaction($reaction) {
    $this->reaction_set[$reaction->id] = $reaction;
  }


  public function addParameter($parameter) {
    // FIXME: warn/die on duplicate names (I don't think SBML requires param name uniqueness *between* reactions)
    $this->parameter_set[$parameter->id] = $parameter;
  }


  public function getSpecies($id) {
    return $this->species_set[$id];
  }


  public function getReaction($id) {
    return $this->reaction_set[$id];
  }


  public function getParameter($id) {
    return $this->parameter_set[$id];
  }


  public function getSpeciesIds() {
    return array_keys($this->species_set);
  }


  public function getReactionIds() {
    return array_keys($this->reaction_set);
  }


  public function getParameterIds() {
    return array_keys($this->parameter_set);
  }


}



class SBWSbmlSpecies extends SBWSbmlEntity {
  
  public $initialConcentration;


  public function asText() {
    return $this->initialConcentration->getBestName() . ' = ' . $this->initialConcentration->asText();
  }
}



class SBWSbmlReaction extends SBWSbmlEntity {
  
  public    $isReversible;
  protected $reactants    = array();
  protected $products     = array();
  protected $parameters   = array();


  public function addReactant($species) {
    $this->reactants[] = $species;
  }


  public function addProduct($species) {
    $this->products[] = $species;
  }


  public function addParameter($parameter) {
    $this->parameters[] = $parameter;
  }


  public function getParameters() {
    return $this->parameters;
  }


  # FIXME: parse mathml for real
  public function asText() {
    return
      implode(' + ', array_map(create_function('$s', 'return $s->getBestName();'), $this->reactants)) .
      ($this->isReversible ? ' <--> ' : ' --> ') .
      implode(' + ', array_map(create_function('$s', 'return $s->getBestName();'), $this->products)) .
      ' (' . implode(', ', array_map(create_function('$p', 'return $p->getBestName();'), $this->parameters)) . ')'
      ;
  }


}



class SBWSbmlParameter extends SBWSbmlEntity {
  
  public $value;


  public function asText() {
    return $this->value;
  }

}



?>
