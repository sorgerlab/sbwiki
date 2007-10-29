<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('UploadAttachFileUID','',true,'doSpecialUploadAttachFileUID',false) );


function doSpecialUploadAttachFileUID() {
  global $wgOut, $wgRequest;

  $uid = $wgRequest->getVal('uid');
  if ( !strlen($uid) ) {
    $wgOut->showErrorPage('missinguid','missinguidtext');
    return;
  }

  $form = new UploadFormUID( $wgRequest );
  $form->mDestFile = $uid;
  $form->execute();
}



class UploadFormUID extends UploadForm {

  function mainUploadForm( $msg='' ) {
    global $wgOut;

    // first, let the original method do its thing
    parent::mainUploadForm($msg);

    // now we perform some modifications to the form html
    $html = $wgOut->getHTML();

    // change destination file input into a hidden form and plain html text
    $sourcefilename = array_pop( explode( '.', $this->mOname ) );
    $encDestFile = htmlspecialchars( $this->mDestFile );
    $html = preg_replace("/type='text' (name='wpDestFile'.*?\/>)/",
                         "type='hidden' $1 <strong>$encDestFile</strong>.???",
                         $html);

    // fix form submit url
    $oldURL = SpecialPage::getTitleFor('Upload')->escapeLocalURL();
    $newURL = SpecialPage::getTitleFor('UploadAttachFileUID')->escapeLocalURL();
    $html = str_replace($oldURL, $newURL, $html);

    // replace html with our modified version
    $wgOut->clearHTML();
    $wgOut->addHTML($html);
  }


  function processUpload() {
    global $wgOut;

    $this->fixupDestExtension();
    parent::processUpload();
  }


  function fixupDestExtension() {
    if ( trim( $this->mOname ) != '' ) {
      #error_log("mOname: ".$this->mOname);
      $regex = '/\..*$/';
      preg_match($regex, $this->mOname, $matches);
      $this->mDestFile = preg_replace($regex, '', $this->mDestFile);
      $this->mDestFile .= $matches[0];
    }
  }

}

?>
