<?php

function sbwfCloneUIDs( $old_uids ) {
  global $wgOut;

  $new_uids = array();

  for ( $i = 0; $i < count($old_uids); $i++ ) {
    $old_uid = sbwfParseUID($old_uids[$i]);
    // reuse parts of old uid, except index 2 which is the id number
    $new_uid = sbwfAllocateUID($old_uid[0], $old_uid[1], $old_uid[3]);
    $new_uids[] = $new_uid;
    $wgOut->addHTML("$i: $old_uids[$i] -> $new_uid\n");
  }

  return $new_uids;
}

?>
