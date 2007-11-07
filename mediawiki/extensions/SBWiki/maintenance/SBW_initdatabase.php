<?php

/**
 * Maintenance script to create the SBWiki database structure
 *
 * @addtogroup Maintenance
 * @author Jeremy Muhlich
 */


$mwRoot = dirname(__FILE__) . '/../../..'; # XXX could break if our dir structure changes
require_once("$mwRoot/maintenance/commandLine.inc");

global $sbwgIP;
$sbwgMIP = "$sbwgIP/maintenance/includes"; # maintenance includes path
$sbwgMRP = "$sbwgIP/maintenance/resources"; # maintenance resources path
require_once("$sbwgMIP/SBW_initdatabase.php");

if( isset( $options['help'] ) ) {
  showHelp();
  exit();
}

$wgOut = new CommandlineOutputPage();

echo("Creating SBWiki database structure\n\n");
sbwfInitDatabase();
echo("\n");


#####################

function showHelp() {
  echo( "Creates the SBWiki database structure.\n\n" );
  echo( "Usage: php SBW_initdatabase.php\n\n" );
}

/**
 * Fake OutputPage class
 *
 * Lets the included code output via $wgOut, thus working in wiki
 * context as well as command line context.
 */
class CommandlineOutputPage {
  var $mBodytext;

  public function addHTML( $text ) { echo $text; }

}


?>