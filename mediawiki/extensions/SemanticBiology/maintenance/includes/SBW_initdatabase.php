<?php

function sbwfInitDatabase( $options=array() ) {
  global $wgOut, $sbwgMRP;

  $sqlfile_create = "$sbwgMRP/sbw_create.sql";

  $wgOut->addHTML("Creating tables...\n");
  $dbw = wfGetDB( DB_MASTER );
  try {
    $error = $dbw->sourceFile($sqlfile_create);
  } catch (Exception $e){
    $error = "$e";
  }

  if ( $error !== true ) {
    $error = preg_replace('/^/m', '  ', $error); # indent text
    $wgOut->addHTML("<pre>Failure!\nError in $sqlfile_create:\n\n$error\n\n\n</pre>");
    return false;
  } else {
    $wgOut->addHTML("  Success!\n");
    return true;
  }
}

?>
