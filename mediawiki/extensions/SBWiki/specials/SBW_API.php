<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );


SpecialPage::addPage( new SpecialPage('SBW_API','',true,'doSpecialAPI',false) );


function doSpecialAPI() {
  global $wgRequest, $wgOut;

  $wgOut->disable();

  $method = $wgRequest->getVal('method');
  switch ($method) {
  case 'list_raw_data': {
    method_list_raw_data($wgRequest);
    break;
  }
  case 'get_file': {
    method_get_file($wgRequest);
    break;
  }
  }

}


function method_list_raw_data($request) {

  header('Content-type: text/plain');

  $query = SMWQueryProcessor::createQuery('[[Category:Raw_data]] [[has attached file::+]]', array());

  if ($query instanceof SMWQuery) { // query parsing successful
    $res = smwfGetStore()->getQueryResult($query);
    while ( $row = $res->getNext() ) {
      $title = $row[0]->getNextHTMLText();
      print "$title\n";
    }
  } else {
    // error string
    print $query;
  }
}


function method_get_file($request) {
  global $wgServer;

  $uid = $request->getVal('uid');

  $query = SMWQueryProcessor::createQuery("[[$uid]] [[has attached file::*]]", array());

  if ($query instanceof SMWQuery) { // query parsing successful
    $res = smwfGetStore()->getQueryResult($query);
    $row = $res->getNext();
    $title = preg_replace('/^Image:/', '', $row[0]->getNextHTMLText());
    $file = Image::newFromName($title);

    header('Content-type: ' . $file->getMimeType());
    header('Content-disposition: filename=' . $file->getName());
    readfile($file->getPath());

  } else {
    // error string
    print $query;
  }
}


?>
