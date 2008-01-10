<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP, $sbwgIP;
require_once( $IP . '/includes/SpecialPage.php' );
require_once( $sbwgIP . '/includes/classes/SBW_SbmlParser.php' );

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
    $parser = new SBWSbmlParser($model_contents);
    $wgOut->addWikiText('== Species ==');
    foreach ( $parser->getSpeciesIds() as $id ) {
      $wgOut->addWikiText('* ' . $parser->getSpecies($id)->name);
    }
    $wgOut->addWikiText('== Reactions ==');
    foreach ( $parser->getReactionIds() as $id ) {
      $reaction = $parser->getReaction($id);
      $wgOut->addWikiText('* ' . $reaction->name . ' : ' . $reaction->asText());
    }



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
