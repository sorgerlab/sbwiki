<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('AddDataUID','',true,'doSpecialAddDataUID',false) );

function doSpecialAddDataUID() {
  global $wgOut, $wgRequest, $wgScriptPath;

  $submitted        = $wgRequest->getVal('create');
  $root_category    = $wgRequest->getVal('root_category');
  $category         = $wgRequest->getVal('category');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotation       = $wgRequest->getVal('annotation');

  $errors = array();

  if ( !$submitted and $user_initials = sbwfGetUserInitials() ) {
    $creator_initials = $user_initials;
  }

  $form = $type_code = $category_list = null;
  if ( $root_category ) {
    $root_category = Title::newFromText($root_category);
    if ( $root_category->exists() ) {
      list($form, $type_code) = sbwfGetCategoryCreateInfo($root_category);
      $category_list = sbwfGetSubcategories($root_category);
      array_unshift($category_list, $root_category);
      if ( !$form )           $errors[] = "<em>$root_category</em> does not have a <em>Has default form</em> property";
      if ( !$form->exists() ) $errors[] = "<em>$form</em> (the default form for <em>$root_category</em>) does not exist";
      if ( !$type_code      ) $errors[] = "<em>$category</em> does not have an <em>Abbreviation</em> property";
    } else {
      $errors[] = "<em>$root_category</em> does not exist";
    }
  } else {
    $errors[] = '<em>root_category</em> not specified';
  }

  if ( $submitted ) {
    if ( !$category )         $errors[] = 'Please choose a <em>Category</em>';
    if ( !$creator_initials ) $errors[] = 'Please enter the <em>Creator Initials</em>';
  }

  if ( $wgRequest->wasPosted() and $submitted and empty($errors) ) {
    $special_adddata_title = Title::makeTitle(NS_SPECIAL, 'AddData');
    $target = sbwfAllocateUID($type_code, $creator_initials, $annotation);
    $url_params = "form=$form&target=$target";
    // TODO decide whether we want to provide the annotation as a semantic relation
    // &Property_label[label]=" . urlencode($annotation);
    $wgOut->redirect($special_adddata_title->getFullURL($url_params));
    return; // success!
  }

  $category_input = null;
  if ( count($category_list) == 1 ) {
    $category_input = '<input name="category" type="hidden" value="' . $category_list[0] . '" />' . $category_list[0]->getText();
  } else {
    $category_input .= 'Please choose the most specific category:<br/><select name="category" style="width: 15em;" size="' . count($category_list) . '">';
    $is_first = true;
    foreach ($category_list as $cat) {
      $category_input .= '<option value="' . $cat . '">' . $cat->getText() . ($is_first ? ' (most general)' : '') . '</option>';
      $is_first = false;
    }
    $category_input .= '</select>';
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
<tr><td><strong>Category:</strong></td><td>$category_input</td></tr>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials"></td></tr>
<tr><td><strong>Annotation (optional):</strong></td><td><input name="annotation" type="text" value="$annotation"></td></tr>
<tr><td></td><td><input name="create" type="submit" value="Create UID"></td></tr>
</table>

<input name="root_category" type="hidden" value="$root_category">
</form>

</div>
FORM
                  );
}
