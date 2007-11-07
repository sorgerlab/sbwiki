<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('ListUIDs','',true,'doSpecialListUIDs',false) );

function doSpecialListUIDs() {
  global $wgOut, $wgRequest;
  $fname = 'SBW::doSpecialListUIDs';

  $type_code        = $wgRequest->getVal('type_code');
  $creator_initials = $wgRequest->getVal('creator_initials');
  $annotation       = $wgRequest->getVal('annotation');
  $count            = $wgRequest->getVal('count');

  $uids = sbwfListUIDs();
  foreach ($uids as $uid) {
    $wgOut->addSecondaryWikiText("[[$uid| $uid]]<br>");
  }
}


