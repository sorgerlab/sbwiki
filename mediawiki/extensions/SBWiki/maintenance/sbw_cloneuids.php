<?php

/**
 * Maintenance script to clone a list of UIDs, changing only the id
 * number.
 *
 * @addtogroup Maintenance
 * @author Jeremy Muhlich
 */


$mwRoot = dirname(__FILE__) . '/../../..'; # XXX could break if our dir structure changes
require_once("$mwRoot/maintenance/commandLine.inc");

global $sbwgIP;
require_once("$sbwgMIP/SBW_MaintenanceHelpers.php");
require_once("$sbwgMIP/SBW_cloneuids.php");

if( isset( $options['help'] ) or $argc < 3 ) {
  echo(<<<USAGE
Clones a list of UIDS, changing only the numeric id component.

Usage: php SBW_cloneuids.php input_uids output_mapping

input_uids
  The input file, a list of the old UIDs.
output_mapping
  The output file, a tab-separated list with old UIDs in the first column,
  and the corresponding cloned UIDs in the second.


USAGE
      );
  exit();
}

echo("Cloning UIDs...\n\n");

$old_uids = array();

$input_file = fopen($args[0], 'r');
if ( !$input_file ) {
  exit;
}
while ( !feof($input_file) ) {
  $uid = trim(fgets($input_file));
  if ( $uid == '' ) { continue; }
  $old_uids[] = $uid;
}
fclose($input_file);

$new_uids = sbwfCloneUIDs($old_uids);

$output_file = fopen($args[1], 'w');
for ( $i = 0; $i < count($old_uids); $i++ ) {
  fwrite($output_file, "$old_uids[$i]\t$new_uids[$i]\n");
}
fclose($output_file);

echo("\n");

?>