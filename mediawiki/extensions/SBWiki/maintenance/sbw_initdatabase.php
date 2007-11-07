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
require_once("$sbwgMIP/SBW_MaintenanceHelpers.php");

if( isset( $options['help'] ) ) {
  echo( "Creates the SBWiki database structure.\n\n" );
  echo( "Usage: php SBW_initdatabase.php\n\n" );
  exit();
}

echo("Creating SBWiki database structure\n\n");
sbwfInitDatabase();
echo("\n");

?>