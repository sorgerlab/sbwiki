<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP, $sbwgIP;
require_once( $IP . '/includes/SpecialPage.php' );
require_once( $sbwgIP . '/includes/classes/SBW_SbmlReader.php' );
require_once( $sbwgIP . '/includes/classes/SBW_ModelFormatter.php' );


SpecialPage::addPage( new SpecialPage('ImportSBMLModel','',true,'doSpecialImportSBMLModel',false) );


function doSpecialImportSBMLModel()
{
  global $wgOut, $wgRequest, $wgScriptPath, $smwgScriptPath;

  $step_2_combine   = $wgRequest->getCheck('step_2_combine');
  $step_3_preview   = $wgRequest->getCheck('step_3_preview');
  $step_4_import    = $wgRequest->getCheck('step_4_import');
  $creator_initials = $wgRequest->getText('creator_initials');
  $model_title      = $wgRequest->getText('model_title');
  $model_contents   = $wgRequest->getText('model_contents');

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
    if ( $step_2_combine ) {
      renderCombine($model_contents, $creator_initials, $model_title);
    } elseif ( $step_3_preview ) {
      renderPreview($model_contents, $creator_initials, $model_title);
    } elseif ( $step_4_import ) {
      importModel($model_contents, $creator_initials, $model_title);
    } else {
      throw new MWException("Post without expected submit button click");
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
<tr><td></td><td><input name="step_2_combine" type="submit" value="Continue"></td></tr>
</table>

</form>

</div>
FORM
		  );
}


function renderCombine($model_contents, $creator_initials, $model_title)
{
  global $wgOut, $wgScriptPath, $smwgScriptPath;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  assignFakeUids($model, $creator_initials, $model_title);

  $model_contents   = htmlspecialchars($model_contents);
  $creator_initials = htmlspecialchars($creator_initials);
  $model_title      = htmlspecialchars($model_title);

  // FIXME: SMW could change this... probably better to copy it and make our own style
  $wgOut->addHeadItem('smw_css',
		      "\t\t" . '<link rel="stylesheet" type="text/css" media="screen, projection" href="' .
		      $smwgScriptPath . '/skins/SMW_custom.css" />' . "\n");
  $wgOut->addWikiText(<<<INTRO
You may now optionally combine model entities (within the same category) to better
match the logical grouping of the model.  When you are done, click the
<strong>Continue</strong> button.

----


INTRO
		      );
  $extra_html .= '<h3>Compartments</h3><table>';
  foreach ( $model->getCompartmentIds() as $id ) {
    $entity = $model->getCompartment($id);
    $name = $entity->getBestName();
    $extra_html .= "<tr><td>$name</td><td><input name=\"\"/ size=\"4\"></td></tr>";
  }
  $extra_html .= '</table>';
  $extra_html .= '<h3>Species</h3><table>';
  foreach ( $model->getSpeciesIds() as $id ) {
    $entity = $model->getSpecies($id);
    $name = $entity->getBestName();
    $extra_html .= "<tr><td>$name</td><td><input name=\"\" size=\"4\"/></td></tr>";
  }
  $extra_html .= '</table>';
  $extra_html .= '<h3>Interactions</h3><table>';
  foreach ( $model->getReactionIds() as $id ) {
    $entity = $model->getReaction($id);
    $name = $entity->getBestName();
    $extra_html .= "<tr><td>$name</td><td><input name=\"\" size=\"4\"/></td></tr>";
  }
  $extra_html .= '</table>';
  $extra_html .= '<h3>Parameters</h3><table>';
  foreach ( $model->getParameterIds() as $id ) {
    $entity = $model->getParameter($id);
    $name = $entity->getBestName();
    $extra_html .= "<tr><td>$name</td><td><input name=\"\"/ size=\"4\"></td></tr>";
  }
  $extra_html .= '</table>';

  renderHiddenForm('step_3_preview', 'Continue', $creator_initials, $model_title, $model_contents, $extra_html);
}


function renderPreview($model_contents, $creator_initials, $model_title)
{
  global $wgOut, $wgScriptPath, $smwgScriptPath;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  assignFakeUids($model, $creator_initials, $model_title);

  $model_contents   = htmlspecialchars($model_contents);
  $creator_initials = htmlspecialchars($creator_initials);
  $model_title      = htmlspecialchars($model_title);

  $formatter = new SBWModelFormatter($parser->getModel());
  // FIXME: SMW could change this... probably better to copy it and make our own style
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

  renderHiddenForm('step_4_import', 'Import', $creator_initials, $model_title, $model_contents);
}


function importModel($model_contents, $creator_initials, $model_title)
{
  global $wgOut;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  $entities = array();

  $model->uid = sbwfAllocateUID('MD', $creator_initials, $model_title);
  $entities[] = $model;

  foreach ( $model->getCompartmentIds() as $id ) {
    $compartment = $model->getCompartment($id);
    $compartment->uid = sbwfAllocateUID('CO', $creator_initials, $compartment->getBestName());
    $entities[] = $compartment;
  }
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


function renderHiddenForm($step, $button_label, $creator_initials, $model_title, $model_contents, $extra_html = '')
{
  global $wgOut, $wgScriptPath;

  $wgOut->addHTML(<<<FORM
<form method="post" action="$wgScriptPath/index.php/Special:ImportSBMLModel">
<input name="creator_initials" type="hidden" value="$creator_initials">
<input name="model_title" type="hidden" value="$model_title">
<input name="model_contents" type="hidden" value="$model_contents">
$extra_html
<input name="$step" type="submit" value="$button_label">
</form>
FORM
		  );
}


function assignFakeUids($model, $creator_initials, $model_title)
{
  // assign fake UIDs for preview display purposes
  $fake_counter = 100;
  $model->uid = sbwfFormatUID('MD', $creator_initials, $fake_counter++, $model_title);
  foreach ( $model->getCompartmentIds() as $id ) {
    $compartment = $model->getCompartment($id);
    $compartment->uid = sbwfFormatUID('CO', $creator_initials, $fake_counter++, $compartment->getBestName());
  }
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
}


?>
