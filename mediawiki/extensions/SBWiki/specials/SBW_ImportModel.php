<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP, $sbwgIP;
require_once( $IP . '/includes/SpecialPage.php' );
require_once( $sbwgIP . '/includes/classes/SBW_SbmlReader.php' );
require_once( $sbwgIP . '/includes/classes/SBW_ModelFormatter.php' );


SpecialPage::addPage( new SpecialPage('ImportModel','',true,'doSpecialImportModel',false) );


function doSpecialImportModel() {
  global $wgOut, $wgRequest, $wgScriptPath;
  $fname = 'SBW::doSpecialImportModel';

  $submitted        = $wgRequest->getVal('import');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotation       = $wgRequest->getVal('annotation');
  $model_contents   = $wgRequest->getVal('model_contents');

  $errors = array();

  if ( !$submitted and $user_initials = sbwfGetUserInitials() ) {
    $creator_initials = $user_initials;
  }
  if ( $submitted ) {
    if ( !$creator_initials ) $errors[] = '<em>Creator Initials</em> not specified';
    if ( !$model_contents   ) $errors[] = '<em>SBML Code</em> not provided';
  }


  if ( $wgRequest->wasPosted() and $submitted and empty($errors) ) {
    // successful form submission (but the SBML might still be invalid)

    $parser = new SBWSbmlReader($model_contents);
    $model = $parser->getModel();

    // assign fake UIDs for preview display purposes
    $fake_counter = 100;
    $model->uid = sbwfFormatUID('MD', $creator_initials, $fake_counter++, $annotation);
    foreach ( $model->getSpeciesIds() as $id ) {
      $species = $model->getSpecies($id);
      $species->uid = sbwfFormatUID('SP', $creator_initials, $fake_counter++, $species->name);
    }
    foreach ( $model->getReactionIds() as $id ) {
      $reaction = $model->getReaction($id);
      $reaction->uid = sbwfFormatUID('RX', $creator_initials, $fake_counter++, $reaction->name);
    }

    $formatter = new SBWModelFormatter($parser->getModel());
    $wgOut->addWikiText(<<<INTRO
Below is a preview of what your model will look like in the wiki.
'''DO NOT CLICK''' on any of the links!

----


INTRO
                        );
    $wgOut->addWikiText($formatter->formatAll());

  } else {

    // first visit or error on submission

    $wgOut->addHTML('<p>This is the page for importing an SBML model.</p>');
    if ( !empty($errors) ) {
      $wgOut->addHTML("<div class=\"errorbox\"><strong>Errors:</strong><ul>");
      foreach ( $errors as $error ) {
        $wgOut->addHTML("<li>$error</li>");
      }
      $wgOut->addHTML("</ul></div><div class=\"visualClear\"></div>");
    }

    $wgOut->addHTML(<<<FORM
<div>

<form method="post" action="$wgScriptPath/index.php/Special:ImportModel">

<table>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials"></td></tr>
<tr><td><strong>Annotation (optional):</strong></td><td><input name="annotation" type="text" value="$annotation"></td></tr>
<tr><td><strong>SBML Code<br/>(paste file contents):</strong></td><td><textarea cols="50" rows="20" name="model_contents"></textarea></td></tr>
<tr><td></td><td><input name="import" type="submit" value="Import Model"></td></tr>
</table>

</form>

</div>
FORM
                    );

  }

}
