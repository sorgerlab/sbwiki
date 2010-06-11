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

    foreach ( $xml->model->listOfCompartments->compartment as $compartment_elt ) {
      $compartment = new SBWSbmlCompartment($compartment_elt['id']);
      $compartment->name = (string) $compartment_elt['name'];
      $sizeParameter = new SBWSbmlParameter($compartment->getBestName() . ' size');
      $sizeParameter->value = (float) $compartment_elt['size'];
      $sizeParameter->notes = "Size of compartment '" . $compartment->getBestName() . "'";
      $compartment->sizeParameter = $sizeParameter;
      $this->parseNotes($compartment, $compartment_elt);
      $model->addParameter($sizeParameter);
      $model->addCompartment($compartment);
    }

    foreach ( $xml->model->listOfSpecies->species as $species_elt ) {
      $species = new SBWSbmlSpecies($species_elt['id']);
      $species->name = (string) $species_elt['name'];
      $initialParameter = new SBWSbmlParameter($species->getBestName() . ' initial');
      foreach ( array('initialConcentration', 'initialAmount') as $key ) {
	if ( $species_elt[$key] != NULL ) {
	  $initialParameter->value = (float) $species_elt[$key];
	}
      }
      if ( !isset($initialParameter->value) ) {
        $initialParameter->value = 'undefined';
      }
      $initialParameter->notes = "Initial concentration of species '" . $species->getBestName() . "'";
      $species->initialParameter = $initialParameter;
      $species->compartment = $model->getCompartment((string) $species_elt['compartment']);
      $this->parseNotes($species, $species_elt);
      $model->addParameter($initialParameter);
      $model->addSpecies($species);
    }

    $model_parameters = $xml->model->listOfParameters->parameter;
    if ( $model_parameters ) {
      foreach ( $model_parameters as $par_elt ) {
	if ( $par_elt['constant'] == 'false' ) {
	  continue;
	}
	$parameter = new SBWSbmlParameter($par_elt['id']);
	$parameter->name  = (string) $par_elt['name'];
	$parameter->value = (float) $par_elt['value'];
	$this->parseNotes($parameter, $par_elt);
	$model->addParameter($parameter);
      }
    }

    foreach ( $xml->model->listOfReactions->reaction as $reaction_elt ) {
      $reaction = new SBWSbmlReaction($reaction_elt['id']);
      $reaction->name         = (string) $reaction_elt['name'];
      $reaction->isReversible = $reaction_elt['reversible'] == 'true';
      foreach ( $reaction_elt->listOfReactants->speciesReference as $speciesref_elt ) {
        $reaction->addReactant($model->getSpecies((string) $speciesref_elt['species']));
      }
      foreach ( $reaction_elt->listOfProducts->speciesReference as $speciesref_elt ) {
        $reaction->addProduct($model->getSpecies((string) $speciesref_elt['species']));
      }
      // extract "local" parameters which are only defined within this reaction
      $reaction_parameters = $reaction_elt->kineticLaw->listOfParameters->parameter;
      $reaction_parameter_ids = array();
      if ($reaction_parameters) {
	foreach ( $reaction_parameters as $par_elt ) {
	  $parameter = new SBWSbmlParameter($par_elt['id']);
	  $parameter->name  = (string) $par_elt['name'];
	  $parameter->value = (float) $par_elt['value'];
	  $this->parseNotes($parameter, $par_elt);
	  $model->addParameter($parameter);
	  $reaction->addParameter($parameter);
	  $reaction_parameter_ids[$parameter->id] = true;
	}
      }
      // look for "global" parameters (defined in the model) referenced from this reaction
      $kineticlaw_identifiers = $this->parseMathIdentifiers($reaction_elt->kineticLaw->math);
      foreach ( $kineticlaw_identifiers as $id ) {
	$parameter = $model->getParameter($id);
	// check that it's a legit parameter name, and not a local param extracted above
	if ( $parameter and !array_key_exists($id, $reaction_parameter_ids) ) {
	  $reaction->addParameter($parameter);
	}
      }
      $this->parseNotes($reaction, $reaction_elt);
      $model->addReaction($reaction);
    }

    $this->model = $model;

  }


  function getModel() {
    return $this->model;
  }


  public function parseNotes($entity, $elt) {
    $notes = '';
    $root_elt = $elt->notes;
    // if there are html/body tags, descend into them
    if ( $root_elt->html ) $root_elt = $root_elt->html;
    if ( $root_elt->body ) $root_elt = $root_elt->body;
    if ( $root_elt ) {
      foreach ($root_elt->children() as $c_elt) {
	$notes .= $c_elt->asXML();
      }
    }
    if (strlen($notes)) $notes = '<html>'.$notes.'</html>'; // FIXME: replace with perl HTML::WikiConverter script
    $entity->notes = $notes;
  }


  private function parseMathIdentifiers($elt) {
    $elt->registerXPathNamespace('mathml', 'http://www.w3.org/1998/Math/MathML');
    $identifier_elts = $elt->xpath('.//mathml:ci');
    $ret = array();
    if ( $identifier_elts ) {
      foreach ( $identifier_elts as $id_elt ) {
	array_push($ret, trim((string) $id_elt));
      }
    }

    return $ret;
  }
}



class SBWSbmlEntity {

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
    $best = strlen($this->name) ? $this->name : $this->id;
    // translate characters not legal in titles to '*'
    $regex_illegal = '/[^' . Title::legalChars() . ']/';
    $best = preg_replace($regex_illegal, '*', $best);

    return $best;
  }

}



class SBWSbmlModel extends SBWSbmlEntity {

  protected $species_set     = array();
  protected $reaction_set    = array();
  protected $parameter_set   = array();
  protected $compartment_set = array();


  public function addSpecies($species) {
    if ( array_key_exists($species->id, $this->species_set) ) {
      throw new RuntimeException("Duplicate species id: '$species->id'");
    }
    $this->species_set[$species->id] = $species;
  }


  public function addReaction($reaction) {
    if ( array_key_exists($reaction->id, $this->reaction_set) ) {
      throw new RuntimeException("Duplicate reaction id: '$reaction->id'");
    }
    $this->reaction_set[$reaction->id] = $reaction;
  }


  public function addParameter($parameter) {
    if ( array_key_exists($parameter->id, $this->parameter_set) ) {
      throw new RuntimeException("Duplicate parameter id: '$parameter->id'");
    }
    $this->parameter_set[$parameter->id] = $parameter;
  }


  public function addCompartment($compartment) {
    if ( array_key_exists($compartment->id, $this->compartment_set) ) {
      throw new RuntimeException("Duplicate compartment id: '$compartment->id'");
    }
    $this->compartment_set[$compartment->id] = $compartment;
  }


  public function getSpecies($id) {
    return array_key_exists($id, $this->species_set) ? $this->species_set[$id] : NULL;
  }


  public function getReaction($id) {
    return array_key_exists($id, $this->reaction_set) ? $this->reaction_set[$id] : NULL;
  }


  public function getParameter($id) {
    return array_key_exists($id, $this->parameter_set) ? $this->parameter_set[$id] : NULL;
  }


  public function getCompartment($id) {
    return array_key_exists($id, $this->compartment_set) ? $this->compartment_set[$id] : NULL;
  }


  public function getEntity($type, $id) {
    switch ( $type ) {
    case 'species':
      return $this->getSpecies($id);
      break;
    case 'interaction':
      return $this->getReaction($id);
      break;
    case 'parameter':
      return $this->getParameter($id);
      break;
    case 'compartment':
      return $this->getCompartment($id);
      break;
    default:
      trigger_error("Unrecognized model entity type: $type", E_USER_ERROR);
    }
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


  public function getCompartmentIds() {
    return array_keys($this->compartment_set);
  }

  public function getIds($type) {
    switch ( $type ) {
    case 'species':
      return $this->getSpeciesIds();
      break;
    case 'interaction':
      return $this->getReactionIds();
      break;
    case 'parameter':
      return $this->getParameterIds();
      break;
    case 'compartment':
      return $this->getCompartmentIds();
      break;
    default:
      trigger_error("Unrecognized model entity type: $type", E_USER_ERROR);
    }
  }


}



class SBWSbmlSpecies extends SBWSbmlEntity {
  
  public $initialParameter;
  public $compartment;


  public function asText() {
    return 'initial = ' . $this->initialParameter->value .
      ' (' . $this->compartment->getBestName() . ')';
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

  // FIXME: support modifiers

  public function addParameter($parameter) {
    $this->parameters[] = $parameter;
  }


  public function getParameters() {
    return $this->parameters;
  }


  // FIXME: parse mathml for real?
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
    return 'value = ' . $this->value;
  }

}



class SBWSbmlCompartment extends SBWSbmlEntity {
  
  public $sizeParameter;


  public function asText() {
    return 'size = ' . $this->sizeParameter->value;
  }

}



?>
