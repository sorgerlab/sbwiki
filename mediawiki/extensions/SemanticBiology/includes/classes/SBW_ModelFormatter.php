<?php

class SBWModelFormatter {

  protected $model;
  protected $pages;
  protected $pages_flat;


  public function SBWModelFormatter($model, $model_title, $page_names) {
    if ( !isset($model) ) {
      trigger_error("No model specified", E_USER_ERROR);
    }
    $this->model = $model;
    $this->initPages($model_title, $page_names);
  }


  public function getModelPage() {
    $tmp = $this->getPages('model');
    return $tmp[0];
  }

  public function getAllPages() {
    return $this->pages_flat;
  }

  public function getPages($type) {
    if ( !array_key_exists($type, $this->pages) ) {
      trigger_error("Unrecognized model entity type: $type", E_USER_ERROR);
    }
    return $this->pages[$type];
  }


  public function getPageForEntity($search_entity) {
    foreach ( $this->pages_flat as $page ) {
      foreach ( $page->model_entities as $entity ) {
	if ( $entity === $search_entity ) {
	  return $page;
	}
      }
    }
    trigger_error("Entity not found in page list", E_USER_ERROR);
  }


  public function format($page) {
    $class = get_class($page->model_entities[0]);
    switch ( $class ) {
    case 'SBWSbmlModel':
      return $this->formatModel();
      break;
    case 'SBWSbmlCompartment':
      return $this->formatCompartment($page);
      break;
    case 'SBWSbmlSpecies':
      return $this->formatSpecies($page);
      break;
    case 'SBWSbmlReaction':
      return $this->formatReaction($page);
      break;
    case 'SBWSbmlParameter':
      return $this->formatParameter($page);
      break;
    default:
      trigger_error("Unrecognized model entity class: $class", E_USER_ERROR);
    }
  }


  public function formatAll() {
    $wikitext = '';

    $wikitext .= "<div style='border: 1px dashed #000000; background: #f8f8f8; padding: .5em;'>\n";
    $wikitext .= "= " . $this->getModelPage()->uid . " =\n";
    //$wikitext .= '<pre>';
    $wikitext .= $this->formatModel();
    //$wikitext .= '</pre>';
    $wikitext .= "</div>\n\n\n";

    foreach ( $this->getPages('compartment') as $page) {
      $wikitext .= "<div style='border: 1px dashed #000000; background: #fff0e0; padding: .5em;'>\n";
      $wikitext .= "= $page->uid =\n";
      //$wikitext .= '<pre>';
      $wikitext .= $this->formatCompartment($page);
      //$wikitext .= '</pre>';
      $wikitext .= "</div>\n\n\n";
    }

    foreach ( $this->getPages('species') as $page ) {
      $wikitext .= "<div style='border: 1px dashed #000000; background: #f0fff0; padding: .5em;'>\n";
      $wikitext .= "= $page->uid =\n";
      //$wikitext .= '<pre>';
      $wikitext .= $this->formatSpecies($page);
      //$wikitext .= '</pre>';
      $wikitext .= "</div>\n\n\n";
    }

    foreach ( $this->getPages('interaction') as $page  ) {
      $wikitext .= "<div style='border: 1px dashed #000000; background: #fffff0; padding: .5em;'>\n";
      $wikitext .= "= $page->uid =\n";
      //$wikitext .= '<pre>';
      $wikitext .= $this->formatReaction($page);
      //$wikitext .= '</pre>';
      $wikitext .= "</div>\n\n\n";
    }

    foreach ( $this->getPages('parameter') as $page ) {
      $wikitext .= "<div style='border: 1px dashed #000000; background: #fff0ff; padding: .5em;'>\n";
      $wikitext .= "= $page->uid =\n";
      //$wikitext .= '<pre>';
      $wikitext .= $this->formatParameter($page);
      //$wikitext .= '</pre>';
      $wikitext .= "</div>\n\n\n";
    }

    $wikitext .= "__NOTOC__\n";

    return $wikitext;
  }


  private function initPages($model_title, $page_names) {
    $this->pages = array();
    $this->pages_flat = array();

    $model_page = new SBWModelComponentPage($model_title);
    $model_page->addEntity($this->model);
    $this->pages['model'] = array($model_page);
    $this->pages_flat[] = $model_page;

    foreach ( array('compartment', 'species', 'interaction', 'parameter') as $type ) {
      $this->pages[$type] = array();
      while ( list($component_id, $title) = each($page_names[$type]) ) {
	if ( !array_key_exists($title, $this->pages[$type]) ) {
	  $page = new SBWModelComponentPage($title);
	  $this->pages[$type][$title] = $page;
	  $this->pages_flat[] = $page;
	}
	$this->pages[$type][$title]->addEntity($this->model->getEntity($type, $component_id));
      }
    }

  }


  private function formatModel() {
    $notes = $this->model->notes;

    $wikitext = <<<WIKI
{{Category model}}
{{Property model language
|model_language=SBML
}}
{{Categoryhelper table end}}

WIKI;

    $content = "";
    $content .= "== SBML Model Components ==\n";
    $content .= "$notes\n";
    $content .= "=== Compartments ===  \n";
    $content .= "{| class=\"sbtable\"\n! Name !! Version of !! Size\n";
    foreach ($this->pages['compartment'] as $page) {
      $content .= "|-\n| [[has compartment::$page->uid]] || ";
      $content .= $this->formatComponentRow($page->uid, array('is version of', 'parameterized by'));
      $content .= "\n";
    }
    $content .= "|}\n\n";

    $content .= "=== Species ===  \n";
    $content .= "{| class=\"sbtable\"\n! Name !! Version of !! Compartment !! Original ID\n";
    foreach ($this->pages['species'] as $page) {
      $content .= "|-\n| [[has species::$page->uid]] || ";
      $content .= $this->formatComponentRow($page->uid, array('is version of', 'located in compartment', 'model component ID'));
      $content .= "\n";
    }
    $content .= "|}\n\n";

    $content .= "=== Reactions ===  \n";
    $content .= "{| class=\"sbtable\"\n! Name !! Reaction scheme !! Original ID\n";
    foreach ($this->pages['interaction'] as $page) {
      $content .= "|-\n| [[has interaction::$page->uid]] || ";
      $content .= $this->formatComponentRow($page->uid, array('interaction definition', 'model component ID'));
      $content .= "\n";
    }
    $content .= "|}\n\n";
      
    $content .= "=== Parameters ===  \n";
    $content .= "{| class=\"sbtable\"\n! Name !! Value !! Source\n";
    foreach ($this->pages['parameter'] as $page) {
      $content .= "|-\n| [[has parameter::$page->uid]] || ";
      $content .= $this->formatComponentRow($page->uid, array('parameter value', 'parameter value source'));
      $content .= "\n";
    }
    $content .= "|}\n\n";
    $content .= "__NOEDITSECTION__\n";

    // fixup bare pipe char in template parameter
    $content = preg_replace("/\|(?! \?)/", "{{!}}", $content);

    $wikitext .= "{{Import generated content\n|content=$content}}\n";

    return $wikitext;
  }


  private function formatSpecies($page) {
    $wikitext = <<<WIKI
{{Category species}}
{{Categoryhelper table end}}

{{Import generated content
|content=
== SBML Species ==

WIKI;

    foreach ( $page->model_entities as $species ) {
      $name   = $species->getBestName();
      $notes  = $species->notes;
      $id     = $species->id;
      $ic_uid = $this->getPageForEntity($species->initialParameter)->uid;
      $compartment_uid = $this->getPageForEntity($species->compartment)->uid;

      $wikitext .= <<<WIKI
=== $name ===
'''Model species ID:''' [[model_component_ID::$id]]<br>
'''Initial condition parameter:''' [[parameterized_by::$ic_uid]]: {{#show: $ic_uid | ?parameter value}}<br>
'''Compartment:''' [[located_in_compartment::$compartment_uid]]<br>
'''Notes:''' $notes

WIKI;
    }

    $wikitext .= "\n----\nThis species is part of the model '[[" . $this->getModelPage()->uid . "]]'\n";
    $wikitext .= "__NOEDITSECTION__\n";
    $wikitext .= "}}\n";

    return $wikitext;
  }


  private function formatReaction($page) {
    $wikitext = <<<WIKI
{{Category interaction}} 
{{Categoryhelper table end}}

{{Import generated content
|content=
== SBML Reactions ==

WIKI;

    foreach ( $page->model_entities as $reaction ) {
      $name   = $reaction->getBestName();
      $notes  = $reaction->notes;
      $id     = $reaction->id;
      $scheme = $reaction->asText();

      $wikitext .= <<<WIKI
=== $name ===
'''Model reaction ID:''' [[model_component_ID::$id]]<br>
'''Reaction scheme:''' [[interaction_definition::$scheme]]<br>
WIKI;

      $wikitext .= "'''Species:'''\n";
      $seen_species = array();  // track previously-displayed species pages to prevent duplicates
      foreach ( $reaction->getSpecies() as $species ) {
	$s_uid = $this->getPageForEntity($species)->uid;
        if ( ! array_key_exists($s_uid, $seen_species) ) {
	  $seen_species[$s_uid] = 1;
	  $wikitext .= "[[has_interaction_participant::$s_uid]] ; ";
	}
      }
      $wikitext .= "<br>";

      $wikitext .= "'''Parameters:'''\n";
      $seen_params = array();  // same as with species above
      foreach ( $reaction->getParameters() as $parameter ) {
	$p_uid = $this->getPageForEntity($parameter)->uid;
        if ( ! array_key_exists($p_uid, $seen_params) ) {
	  $seen_params[$p_uid] = 1;
	  $wikitext .= "[[parameterized_by::$p_uid]]: {{#show: $p_uid | ?parameter value}} ; ";
	}
      }
      $wikitext .= "<br>";

      $wikitext .= "'''Notes:''' $notes\n";
    }

    $wikitext .= "\n----\nThis interaction is part of the model '[[" . $this->getModelPage()->uid . "]]'\n";
    $wikitext .= "__NOEDITSECTION__\n";
    $wikitext .= "}}\n";

    return $wikitext;
  }


  private function formatParameter($page) {
    $wikitext = <<<WIKI
{{Category parameter}}
{{Categoryhelper table end}}

{{Import generated content
|content=
== SBML Parameters ==

WIKI;

    foreach ( $page->model_entities as $parameter ) {

      $name = $parameter->getBestName();
      $notes = $parameter->notes;
      $id    = $parameter->id;
      $value = $parameter->value;

      $wikitext .= <<<WIKI
=== $name ===
'''Model parameter ID:''' [[model_component_ID::$id]]<br>
'''Value:''' [[parameter_value::$id = $value]]<br>
'''Notes:''' $notes

WIKI;
    }

    $wikitext .= "\n----\nThis parameter is part of the model '[[" . $this->getModelPage()->uid . "]]'\n";
    $wikitext .= "__NOEDITSECTION__\n";
    $wikitext .= "}}\n";

    return $wikitext;
  }


  private function formatCompartment($page) {
    $wikitext = <<<WIKI
{{Category compartment}}
{{Categoryhelper table end}}

{{Import generated content
|content=
== SBML Compartments ==

WIKI;

    foreach ( $page->model_entities as $compartment) {
      $name   = $compartment->getBestName();
      $notes  = $compartment->notes;
      $id     = $compartment->id;
      $param_uid = $this->getPageForEntity($compartment->sizeParameter)->uid;

      $species_uids = array(); // data to be stored in keys, not values!
      foreach ( $this->model->getSpeciesIds() as $species_id ) {
	$species = $this->model->getSpecies($species_id);
	if ( $species->compartment == $compartment ) {
	  $species_uid = $this->getPageForEntity($species)->uid;
	  $species_uids[$species_uid] = 1;
	}
      }
      if ( count($species_uids) ) {
	$uids_temp = array_keys($species_uids);
	sort($uids_temp);
	$species_text = implode(", ", array_map(create_function('$uid', 'return "[[$uid]]";'), $uids_temp));
      } else {
	// A compartment with no species is unlikely, but I think it's legitimate SBML.
	$species_text = 'NONE';
      }


      $wikitext .= <<<WIKI
=== $name ===
'''Model compartment ID:''' [[model_component_ID::$id]]<br>
'''Size parameter:''' [[parameterized_by::$param_uid]]: {{#show: $param_uid | ?parameter value}}<br>
'''Contained species:''' : $species_text<br>
'''Notes:''' $notes

WIKI;
    }

    $wikitext .= "\n----\nThis compartment is part of the model '[[" . $this->getModelPage()->uid . "]]'\n";
    $wikitext .= "__NOEDITSECTION__\n";
    $wikitext .= "}}\n";

    return $wikitext;
  }


  private function formatComponentRow($uid, $properties) {
    return implode(" || ", array_map(create_function('$p', "return \"{{#show: $uid | ?\$p}}\";"), $properties));
  }

}



class SBWModelComponentPage {

  public $uid;
  public $base_name;
  public $model_entities;

  public function SBWModelComponentPage($base_name) {
    $this->base_name = $base_name;
    $this->model_entities = array();
  }

  public function addEntity($entity) {
    $this->model_entities[] = $entity;
  }

}

?>
