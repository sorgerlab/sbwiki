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

  $result = sbwfSemanticQuery('[[Category:Raw_data]] [[has attached file::+]]',
			      array('?has attached file'));

  while ( $row = $result->getNext() ) {
    $filename = $row[1]->getNextHTMLText();
    $filename = preg_replace('/^Image:/', '', $filename);
    $filename = strtr($filename, ' ', '_');
    print "$filename\n";
  }
}


function method_get_file($request) {
  global $wgServer;

  $filename = $request->getVal('filename');

  $file = Image::newFromName($filename);

  header('Content-type: ' . $file->getMimeType());
  header('Content-disposition: filename=' . $file->getName());
  readfile($file->getPath());
}


?>
