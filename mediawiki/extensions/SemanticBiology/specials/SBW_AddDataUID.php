<?php

if ( !defined('MEDIAWIKI') ) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );
require_once( $sbwgIP . '/includes/classes/SBW_CategoryTree.php' );

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

  # either category or root_category must be specified
  
  $form = $type_code = $category_list = null;
  if ( $category ) {
    $category_title = Title::newFromText($category, NS_CATEGORY);
    if ( !$category_title->exists() ) {
      $errors[] = "category <em>$category</em> does not exist";
    }
  } else {
    if ( $root_category ) {
      $root_category = Title::newFromText($root_category, NS_CATEGORY);
      if ( $root_category->exists() ) {
        $category_tree = new SBWCategoryTree($root_category);
        $ct_entries = $category_tree->getEntries();
        if ( count($ct_entries) == 1 ) {
          $category_title = $ct_entries[0]->title;
        }
      } else {
	$errors[] = "category <em>$root_category</em> does not exist";
      }
    } else {
      $errors[] = '<em>root_category</em> not specified';
    }
  }

  if ( $submitted ) {
    if ( !$category ) {
      $errors[] = 'Please choose a <em>Category</em>';
    } else {
      list($form, $type_code) = sbwfGetCategoryCreateInfo($category);
      if ( !$form )           $errors[] = "category <em>$category</em> does not have a <em>Has default form</em> property";
      if ( !$form->exists() ) $errors[] = "<em>$form</em> (the default form for <em>$root_category</em>) does not exist";
      if ( !$type_code      ) $errors[] = "category <em>$category</em> does not have an <em>Abbreviation</em> property";
    }
    if ( !$annotation )       $errors[] = 'Please enter the <em>Title</em>';
    if ( !$creator_initials ) $errors[] = 'Please enter the <em>Creator Initials</em>';
  }

  if ( $wgRequest->wasPosted() and $submitted and empty($errors) ) {
    $special_adddata_title = Title::makeTitle(NS_SPECIAL, 'FormEdit');
    $form_base = $form->getText();
    $target = sbwfAllocateUID($type_code, $creator_initials, $annotation);
    $url_params = "form=$form_base&target=$target";
    // TODO decide whether we want to provide the annotation as a semantic relation
    // &Property_label[label]=" . urlencode($annotation);
    $wgOut->redirect($special_adddata_title->getFullURL($url_params));
    return; // success!
  }

  $category_input = '';
  if ( isset($category_title) ) {
    $category_input = '<input name="category" type="hidden" value="' . $category_title . '" />' . $category_title->getText();
  } elseif ( isset($category_tree) ) {
    $entries = $category_tree->getEntries();
    $category_input .= 'Please choose the most specific category:<br/><select name="category" style="width: 15em;" size="' . count($entries) . '">';
    $is_first = true;
    foreach ($entries as $e) {
      $text = str_repeat('&nbsp;&nbsp;&nbsp;&nbsp;', $e->depth) . '&bull; ' . $e->title->getText() . ($is_first ? ' (most general)' : '');
      //$text = str_repeat('&nbsp;&nbsp;&nbsp;&nbsp;', $e->depth - 1) . ($e->depth > 0 ? '+--- ' : '') . $e->title->getText() . ($is_first ? ' (most general)' : '');
      $category_input .= '<option value="' . $e->title . '">' . $text . '</option>';
      $is_first = false;
    }
    $category_input .= '</select>';
  }

  $wgOut->addHTML('<p>This is the page for creating a new UID and then editing its fields.  All fields are required.</p>');
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
<tr><td><strong>Title:</strong></td><td><input name="annotation" type="text" value="$annotation" size="50"></td></tr>
<tr><td><strong>Category:</strong></td><td>$category_input</td></tr>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials" size="4"></td></tr>
<tr><td></td><td><input name="create" type="submit" value="Create UID"></td></tr>
</table>

<input name="root_category" type="hidden" value="$root_category">
</form>

</div>
FORM
                  );
}
