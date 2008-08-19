<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('AddDataUID','',true,'doSpecialAddDataUID',false) );

function doSpecialAddDataUID() {
  global $wgOut, $wgRequest, $wgScriptPath;
  $fname = 'SBW::doSpecialAddDataUID';

  $submitted        = $wgRequest->getVal('create');
  $lock_core_fields = $wgRequest->getVal('lock_core_fields');
  $form             = $wgRequest->getVal('form');
  $type_code        = $wgRequest->getVal('type_code');
  $category         = $wgRequest->getVal('category');
  $allowable_types  = $wgRequest->getVal('allowable_types');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotation       = $wgRequest->getVal('annotation');

  $errors = array();

  if ( !$submitted and $user_initials = sbwfGetUserInitials() ) {
    $creator_initials = $user_initials;
  }
  if ( $category ) {
    list($form, $type_code, $category_error) = sbwfGetCategoryCreateInfo($category);
    if ( $category_error ) {
      $errors[] = "<em>Category:$category</em>: $category_error";
    } else {
      if ( !$form )      $errors[] = "<em>Category:$category</em> does not have a <em>Has default form</em> property (form)";
      if ( !$type_code ) $errors[] = "<em>Category:$category</em> does not have an <em>Abbreviation</em> property (type_code)";
    }
  }
  if ( $form ) {
    $form_title = Title::newFromText($form, SF_NS_FORM);
    if ( !$form_title or !$form_title->exists() ) {
      $errors[] = 'No form page was found at ' . sffLinkText(SF_NS_FORM, $form);
    }
  }
  if ( $submitted ) {
    if ( !$form )             $errors[] = '<em>Form</em> not specified';
    if ( !$type_code )        $errors[] = '<em>Type Code</em> not specified';
    if ( !$creator_initials ) $errors[] = '<em>Creator Initials</em> not specified';
  }

  if ( $wgRequest->wasPosted() and $submitted and empty($errors) ) {
    $formArticle = new Article($form_title);
    $special_adddata_title = Title::makeTitle(NS_SPECIAL, 'AddData');
    $target = sbwfAllocateUID($type_code, $creator_initials, $annotation);
    $url_params = "form=$form&target=$target";
    // TODO decide whether we want to provide the annotation as a semantic relation
    // &Property_label[label]=" . urlencode($annotation);
    $wgOut->redirect($special_adddata_title->getFullURL($url_params));
    return; // success!
  }

  // prevent form and type_code editing if lock_core_fields is set (e.g. in an incoming link)
  if ( $lock_core_fields and $form and $type_code ) {
    $form_input = "<input name=\"form\" type=\"hidden\" value=\"$form\">$form";
    $type_code_input = "<input name=\"type_code\" type=\"hidden\" value=\"$type_code\">$type_code";
  } else {
    $form_input = "<input name=\"form\" type=\"text\" value=\"$form\">";
    $type_code_input = "<input name=\"type_code\" type=\"text\" value=\"$type_code\">";
  }

  $wgOut->addHTML('<p>This is the page for creating a new UID and then editing its fields.</p>');
  if ( !empty($errors) ) {
    $wgOut->addHTML("<div class=\"errorbox\"><strong>Errors:</strong><ul>");
    foreach ( $errors as $error ) {
      $wgOut->addHTML("<li>$error</li>");
    }
    $wgOut->addHTML("</ul></div><div class=\"visualClear\"></div>");
  }

  $wgOut->addHTML(<<<FORM
<div>

<form method="post" action="$wgScriptPath/index.php/Special:AddDataUID">

<table>
<tr><td><strong>Semantic Form:</strong></td><td>$form_input</td></tr>
<tr><td><strong>Type Code:</strong></td><td>$type_code_input</td></tr>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials"></td></tr>
<tr><td><strong>Annotation (optional):</strong></td><td><input name="annotation" type="text" value="$annotation"></td></tr>
<tr><td></td><td><input name="create" type="submit" value="Create UID"></td></tr>
</table>

<input name="lock_core_fields" type="hidden" value="$lock_core_fields">
</form>

</div>
FORM
                  );
}


