<?php

/**
 * Command line scripts can include this file so that any include'd
 * code that calls $wgOut->addHTML will still display the text at the
 * command line.
 */

global $wgOut;
$wgOut = new CommandlineOutputPage();


/**
 * Fake OutputPage class for command line context.
 */
class CommandlineOutputPage {
  var $mBodytext;

  public function addHTML( $text ) { echo $text; }

}

?>
