<?php

function sbwfInitDatabase( $options=array() ) {
  global $wgOut, $sbwgMRP;

  $sqlfile_create = "$sbwgMRP/sbw_create.sql";

  $wgOut->addHTML("Creating tables...\n");
  $dbw = wfGetDB( DB_MASTER );
  $error = $dbw->sourceFile($sqlfile_create);

  if ( $error !== true ) {
    $error = preg_replace('/^/m', '  ', $error); # indent text
    $wgOut->addHTML("  Failure!\n  Error in $sqlfile_create:\n  -----\n$error\n  -----\n\n");
    return;
  } else {
    $wgOut->addHTML("  Success!\n");
  }
}

?>
