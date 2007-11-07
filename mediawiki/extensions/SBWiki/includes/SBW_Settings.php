<?php

###
# This is the path to your installation of SBW as
# seen from the web. Change it if required ($wgScriptPath is the
# path to the base directory of your wiki). No final slash.
##
$sbwgScriptPath = $wgScriptPath . '/extensions/SBWiki';
##

###
# This is the path to your installation of SBW as
# seen on your local filesystem. Used against some PHP file path
# issues.
##
$sbwgIP = $IP . '/extensions/SBWiki';
$sbwgMIP = "$sbwgIP/maintenance/includes";  # maintenance includes path
$sbwgMRP = "$sbwgIP/maintenance/resources"; # maintenance resources path
##


// PHP fails to find relative includes at some level of inclusion:
//$pathfix = $IP . $sbwScriptPath;

// load global functions
require_once('SBW_GlobalFunctions.php');

?>
