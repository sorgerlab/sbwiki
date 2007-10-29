<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('GenerateUIDList','',true,'doSpecialGenerateUIDList',false) );

function doSpecialGenerateUIDList() {
  global $wgOut, $wgRequest;
  $fname = 'SBW::doSpecialAddDataUID';

  $type_code        = $wgRequest->getVal('type_code');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotation       = $wgRequest->getVal('annotation');
  $count            = $wgRequest->getVal('count');

  if ( $type_code == '' ) {
    $text = "<p>Error: no type_code specified.</p>\n";
  } elseif ( $creator_initials == '' ) {
    $text = "<p>Error: no creator_initials specified.</p>\n";
  } elseif ( $count <= 0 ) {
    $text = "<p>Error: count must be 1 or greater</p>\n";
  } else {
    $text = "<strong>You allocated the following list of titles:</strong><br>";
    $titles = array();
    for ($i = 0; $i < $count; $i++) {
      $page_title = sbwfAllocateUID($type_code, $creator_initials, $annotation);
      array_push($titles, $page_title);
      $text .= "$page_title<br>";
    }
  }

  $wgOut->addHTML($text);
}


