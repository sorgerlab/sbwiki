<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP, $sbwgIP;
require_once( $IP . '/includes/SpecialPage.php' );
require_once( $sbwgIP . '/includes/classes/SBW_SbmlReader.php' );
require_once( $sbwgIP . '/includes/classes/SBW_ModelFormatter.php' );


SpecialPage::addPage( new SpecialPage('ImportSBMLModel','',true,'doSpecialImportSBMLModel',false) );


function doSpecialImportSBMLModel() {
  global $wgOut, $wgRequest, $wgScriptPath, $smwgScriptPath;
  $fname = 'SBW::doSpecialImportSBMLModel';

  $do_preview       = $wgRequest->getVal('preview');
  $do_import        = $wgRequest->getVal('import');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $model_title      = $wgRequest->getVal('model_title');
  $model_contents   = $wgRequest->getVal('model_contents');

  $errors = array();

  if ( $wgRequest->wasPosted() ) {
    if ( !$creator_initials ) $errors[] = '<em>Creator Initials</em> not specified';
    if ( !$model_title )      $errors[] = '<em>Model Title</em> not specified';
    if ( !$model_contents   ) $errors[] = '<em>SBML Code</em> not provided';
  } elseif ( $user_initials = sbwfGetUserInitials() ) {
    $creator_initials = $user_initials;
  }


  if ( $wgRequest->wasPosted() and empty($errors) ) {
    // successful form submission
    if ( $do_preview ) {
      renderPreview($model_contents, $creator_initials, $model_title);
    } elseif ( $do_import ) {
      importModel($model_contents, $creator_initials, $model_title);
    }
  } else {
    // first visit or error on submission
    renderUploadForm($errors, $creator_initials, $model_title);
  }

}


function renderUploadForm($errors, $creator_initials, $model_title)
{
  global $wgOut, $wgScriptPath;

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

<form method="post" action="$wgScriptPath/index.php/Special:ImportSBMLModel">

<table>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials"></td></tr>
<tr><td><strong>Model Title:</strong></td><td><input name="model_title" type="text" value="$model_title"></td></tr>
<tr><td><strong>SBML Code<br/>(paste file contents):</strong></td><td><textarea cols="50" rows="20" name="model_contents"></textarea></td></tr>
<tr><td></td><td><input name="preview" type="submit" value="Continue"></td></tr>
</table>

</form>

</div>
FORM
		  );
}


function renderPreview($model_contents, $creator_initials, $model_title)
{
  global $wgOut, $wgScriptPath, $smwgScriptPath;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();

  // assign fake UIDs for preview display purposes
  $fake_counter = 100;
  $model->uid = sbwfFormatUID('MD', $creator_initials, $fake_counter++, $model_title);
  foreach ( $model->getSpeciesIds() as $id ) {
    $species = $model->getSpecies($id);
    $species->uid = sbwfFormatUID('SP', $creator_initials, $fake_counter++, $species->getBestName());
  }
  foreach ( $model->getReactionIds() as $id ) {
    $reaction = $model->getReaction($id);
    $reaction->uid = sbwfFormatUID('IX', $creator_initials, $fake_counter++, $reaction->getBestName());
  }
  foreach ( $model->getParameterIds() as $id ) {
    $parameter = $model->getParameter($id);
    $parameter->uid = sbwfFormatUID('PA', $creator_initials, $fake_counter++, $parameter->getBestName());
  }

  $model_contents   = htmlspecialchars($model_contents);
  $creator_initials = htmlspecialchars($creator_initials);
  $model_title      = htmlspecialchars($model_title);

  $formatter = new SBWModelFormatter($parser->getModel());
# FIXME: SMW could change this... probably better to copy it and make our own style
  $wgOut->addHeadItem('smw_css',
		      "\t\t" . '<link rel="stylesheet" type="text/css" media="screen, projection" href="' .
		      $smwgScriptPath . '/skins/SMW_custom.css" />' . "\n");
  $wgOut->addWikiText(<<<INTRO
Below is a preview of what your model will look like in the wiki.
'''DO NOT CLICK''' on any of the links!  If you are satisfied with the preview,
click the <strong>Import</strong> button at the bottom of this page.

----


INTRO
                        );
  $wgOut->addWikiText($formatter->formatAll());

  $wgOut->addHTML(<<<FORM
<form method="post" action="$wgScriptPath/index.php/Special:ImportSBMLModel">
<input name="creator_initials" type="hidden" value="$creator_initials">
<input name="model_title" type="hidden" value="$model_title">
<input name="model_contents" type="hidden" value="$model_contents">
<input name="import" type="submit" value="Import">
</form>
FORM
		  );
}


function importModel($model_contents, $creator_initials, $model_title)
{
  global $wgOut;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  $entities = array();

  $model->uid = sbwfAllocateUID('MD', $creator_initials, $model_title);
  $entities[] = $model;

  foreach ( $model->getSpeciesIds() as $id ) {
    $species = $model->getSpecies($id);
    $species->uid = sbwfAllocateUID('SP', $creator_initials, $species->getBestName());
    $entities[] = $species;
  }
  foreach ( $model->getReactionIds() as $id ) {
    $reaction = $model->getReaction($id);
    $reaction->uid = sbwfAllocateUID('IX', $creator_initials, $reaction->getBestName());
    $entities[] = $reaction;
  }
  foreach ( $model->getParameterIds() as $id ) {
    $parameter = $model->getParameter($id);
    $parameter->uid = sbwfAllocateUID('PA', $creator_initials, $parameter->getBestName());
    $entities[] = $parameter;
  }

  $formatter = new SBWModelFormatter($model);
  $success_titles = array();
  $error_titles = array();
  foreach ( $entities as $entity ) {
    $title = Title::newFromText($entity->uid);
    $article = new Article($title);
    $text = $formatter->format($entity);
    $result = $article->doEdit($text, "model import");
    if ( $result ) {
      $success_titles[] = $title;
    } else {
      $error_titles[] = $title;
    }
  }

  if ( !$error_titles ) {
    $wgOut->addWikiText("Model imported successfully.  The following pages were created:\n");
    foreach ($success_titles as $title) $wgOut->addWikiText("* [[$title]]\n");
  } else {
    $wgOut->addWikiText("Errors during import on the following pages:\n");
    foreach ($error_titles as $title) $wgOut->addWikiText("* $title\n");
  }
}


?>
