<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('GenerateUIDList','',true,'doSpecialGenerateUIDList',false) );

function doSpecialGenerateUIDList() {
  global $wgOut, $wgRequest, $wgScriptPath;

  $type_code        = $wgRequest->getVal('type_code');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotations      = $wgRequest->getVal('annotations');

  if ( $wgRequest->wasPosted() ) {

    $annotation_list = explode("\n", $annotations);
    $annotation_list = preg_replace('/^\s*(.*?)\s*$/', '$1', $annotation_list);
    $annotation_list = array_filter($annotation_list, create_function('$a','return $a != "";'));

    if ( $type_code == '' ) {
      $text = "<p>Error: no type_code specified.</p>\n";
    } elseif ( $creator_initials == '' ) {
      $text = "<p>Error: no creator_initials specified.</p>\n";
    } elseif ( count($annotation_list) == 0 ) {
      $text = "<p>Error: no annotations specified</p>\n";
    } else {
      $text = "<strong>You allocated the following UIDs:</strong><br>";
      $titles = array();
      foreach ($annotation_list as $annotation) {
        $page_title = sbwfAllocateUID($type_code, $creator_initials, $annotation);
        array_push($titles, $page_title);
        $text .= "$page_title<br>";
      }
    }

    $wgOut->addHTML($text);

  } else {

    $wgOut->addHTML(<<<FORM
<p>Create a list of new UIDs, one per annotation.</p>

<div>

<form method="post" action="$wgScriptPath/index.php/Special:GenerateUIDList">

<table>
<tr><td><strong>Type Code:</strong></td><td><input name="type_code" value="$type_code"></td></tr>
<tr><td><strong>Creator Initials:</strong></td><td><input name="creator_initials" type="text" value="$creator_initials"></td></tr>
<tr><td><strong>Annotations (one per line):</strong></td><td><textarea name="annotations">$annotations</textarea></td></tr>
<tr><td></td><td><input name="create" type="submit" value="Create UIDs"></td></tr>
</table>

<input name="lock_core_fields" type="hidden" value="$lock_core_fields">
</form>

</div>
FORM
                    );

  }

}


