<?php

if (!defined('MEDIAWIKI')) die();

global $IP;
require_once( "$IP/includes/SpecialPage.php" );

SpecialPage::addPage( new SpecialPage('UploadAttachFileUID','',true,'doSpecialUploadAttachFileUID',false) );


function doSpecialUploadAttachFileUID() {
  global $wgRequest;

  $uid = $wgRequest->getVal('uid');

  $form = new UploadFormUID( $wgRequest );
  $form->mUid = $uid; // FIXME: should override constructor and do this there
  $form->execute();
}



class UploadFormUID extends UploadForm {

  var $mUid;

  function mainUploadForm( $msg='' ) {
    global $wgOut, $wgAjaxUploadDestCheck;

    if ( !strlen($this->mUid) ) {
      $wgOut->showErrorPage('missinguid','missinguidtext');
      return;
    }

    $this->mDesiredDestName = $this->mUid;

    // first, let the original method do its thing, disabling the ajax
    // destination filename stuff (via a global variable, ugh)
    $oldAUDC = $wgAjaxUploadDestCheck;
    $wgAjaxUploadDestCheck = false;
    parent::mainUploadForm($msg);
    $wgAjaxUploadDestCheck = $oldAUDC;

    // now we perform some modifications to the form html
    $html = $wgOut->getHTML();

    // change destination file input into a hidden form and plain html text
    $encDestName = htmlspecialchars( $this->mDesiredDestName );
    $html = preg_replace("/type='text' (name='wpDestFile'.*?\/>)/s",
                         "type='hidden' $1 <strong>$encDestName</strong>.??? " .
                           "<input type='hidden' name='uid' value='".$this->mUid."'/>",
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
    $this->fixupDestExtension();
    parent::processUpload();
  }


  function fixupDestExtension() {
    if ( trim( $this->mSrcName ) != '' ) {
      // append extension from upload filename to destination filename
      preg_match('/\..*$/', $this->mSrcName, $extension_match);
      $this->mDesiredDestName .= $extension_match[0];
    }
  }

}

?>
