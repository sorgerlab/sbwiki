<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP, $sbwgIP;
require_once( $IP . '/includes/SpecialPage.php' );
require_once( $sbwgIP . '/includes/classes/SBW_SbmlReader.php' );
require_once( $sbwgIP . '/includes/classes/SBW_ModelFormatter.php' );


SpecialPage::addPage( new SpecialPage('ImportSBMLModel','',true,'doSpecialImportSBMLModel',false) );


global $type_codes;
$type_codes = array('model' => 'MD', 'compartment' => 'CO', 'species' => 'SP', 'interaction' => 'IX', 'parameter' => 'PA');


function doSpecialImportSBMLModel()
{
  global $wgOut, $wgRequest, $wgScriptPath, $smwgScriptPath;

  $step_2_combine   = $wgRequest->getCheck('step_2_combine');
  //$step_x_preview   = $wgRequest->getCheck('step_x_preview');
  $step_3_import    = $wgRequest->getCheck('step_3_import');
  $creator_initials = $wgRequest->getText('creator_initials');
  $model_title      = $wgRequest->getText('model_title');
  $model_contents   = $wgRequest->getText('model_contents');
  $page_names       = $wgRequest->getArray('page_names');

  // manage encoded page_names array from single hidden form field
  $page_names_encoded = $wgRequest->getText('page_names');
  if ( strlen($page_names_encoded) ) {
    $page_names = unserialize(base64_decode($page_names_encoded));
  }

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
    /*
    } elseif ( $step_x_preview ) {
      renderPreview($model_contents, $creator_initials, $model_title, $page_names);
    */
    } elseif ( $step_3_import ) {
      importModel($model_contents, $creator_initials, $model_title, $page_names);
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
  global $wgOut, $wgScriptPath, $smwgScriptPath, $sbwgScriptPath;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();

  $model_contents   = htmlspecialchars($model_contents);
  $creator_initials = htmlspecialchars($creator_initials);
  $model_title      = htmlspecialchars($model_title);

  // FIXME: SMW could change this... probably better to copy it and make our own style
  $wgOut->addHeadItem('smw_css',
		      "\t\t" . '<link rel="stylesheet" type="text/css" media="screen, projection" href="' .
		      $smwgScriptPath . '/skins/SMW_custom.css" />' . "\n");
  $wgOut->addScript('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js"></script>' . "\n");
  $wgOut->addScript('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.0/jquery-ui.min.js"></script>' . "\n");
  $wgOut->addScript('<script type="text/javascript" src="' . $sbwgScriptPath . '/skins/SBW_importsbml.js"></script>' . "\n");

  $wgOut->addWikiText(<<<INTRO
You may now optionally combine model entities (within the same category) to better
match the logical grouping of the model.  When you are done, click the
<strong>Continue</strong> button.

----


INTRO
		      );

  $extra_html = '';

  foreach ( array('compartment', 'species', 'interaction', 'parameter') as $type ) {

    $type_pretty = ucfirst($type);
    $extra_html .= <<<HTML
<h3>$type_pretty</h3>
<table class="sbw-importsbml-combine">
<tr>
  <th>Source model element name (ID)</th>
  <th>Destination wiki page title</th>
</tr>
HTML
    ;
    foreach ( $model->getIds($type) as $id ) {
      $entity = $model->getEntity($type, $id);
      $name = $entity->getBestName();
      $entity_extra = '';
      if ( $entity instanceof SBWSbmlReaction ) {
	$entity_extra = $entity->asText();
      }
      $extra_html .= <<<HTML
<tr>
  <td>$name ($id) $entity_extra</td>
  <td><input name="page_names[$type][$id]" value="$name"/></td>
</tr>
HTML
	;
    }
    $extra_html .= '</table>';
  }

  renderHiddenForm('step_3_import', 'Continue', $creator_initials, $model_title, $model_contents, null, $extra_html);
}


// preview is disabled -- turned out to be too confusing in practice
/*
function renderPreview($model_contents, $creator_initials, $model_title, $page_names)
{
  global $wgOut, $wgScriptPath, $smwgScriptPath;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  $formatter = new SBWModelFormatter($model, $model_title, $page_names);
  assignFakeUids($model, $formatter, $creator_initials, $model_title);

  $model_contents   = htmlspecialchars($model_contents);
  $creator_initials = htmlspecialchars($creator_initials);
  $model_title      = htmlspecialchars($model_title);

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

  renderHiddenForm('step_4_import', 'Import', $creator_initials, $model_title, $model_contents, $page_names);
}
*/


function importModel($model_contents, $creator_initials, $model_title, $page_names)
{
  global $wgOut, $type_codes;

  $parser = new SBWSbmlReader($model_contents);
  $model = $parser->getModel();
  $formatter = new SBWModelFormatter($model, $model_title, $page_names);

  while ( list($type, $code) = each($type_codes) ) {
    foreach ( $formatter->getPages($type) as $page ) {
      $page->uid = sbwfAllocateUID($code, $creator_initials, $page->base_name);
    }
  }

  $success_titles = array();
  $error_titles = array();
  foreach ( $formatter->getAllPages() as $page ) {
    $title = Title::newFromText($page->uid);
    $article = new Article($title);
    $text = $formatter->format($page);
    $result = $article->doEdit($text, "model import");
    if ( $result ) {
      $success_titles[] = $title;
    } else {
      $error_titles[] = $title;
    }
  }

  if ( !$error_titles ) {
    $wgOut->addWikiText("Model imported successfully.  [[$success_titles[0]|View your imported model '$success_titles[0]' here]].\n");
  } else {
    $wgOut->addWikiText("Errors during import on the following pages:\n");
    foreach ($error_titles as $title) $wgOut->addWikiText("* $title\n");
  }
}


function renderHiddenForm($step, $button_label, $creator_initials, $model_title, $model_contents, $page_names = null, $extra_html = '')
{
  global $wgOut, $wgScriptPath;

  $page_names_encoded = '';
  if ( $page_names ) {
    $page_names_encoded = base64_encode(serialize($page_names));
  }

  $wgOut->addHTML(<<<FORM
<form method="post" action="$wgScriptPath/index.php/Special:ImportSBMLModel">
<input name="creator_initials" type="hidden" value="$creator_initials">
<input name="model_title" type="hidden" value="$model_title">
<input name="model_contents" type="hidden" value="$model_contents">
<input name="page_names" type="hidden" value="$page_names_encoded">
$extra_html
<input name="$step" type="submit" value="$button_label">
</form>
FORM
		  );
}


/* assign fake UIDs for preview display purposes */
function assignFakeUids($model, $formatter, $creator_initials, $model_title)
{
  global $type_codes;

  $fake_counter = 100;

  while ( list($type, $code) = each($type_codes) ) {
    foreach ( $formatter->getPages($type) as $page ) {
      $page->uid = sbwfFormatUID($code, $creator_initials, $fake_counter++, $page->base_name);
    }
  }
}


?>
