<?php

function sbwfInitDatabase( $options=array() ) {
  global $wgOut, $sbwgMP;

  $wgOut->addHTML("Creating tables...\n");
  $dbw = wfGetDB( DB_MASTER );
  $error = $dbw->sourceFile("$sbwgMP/sbw_create.sql");
  if ( $error !== true ) {
    $error = preg_replace('/^/m', '  ', $error); # indent text
    $wgOut->addHTML("  Failure!  Error follows:\n  -----\n$error\n  -----\n\n");
    return;
  } else {
    $wgOut->addHTML("  Success!\n");
  }
}

?>
