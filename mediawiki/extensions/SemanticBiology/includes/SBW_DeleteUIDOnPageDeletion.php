<?php
global $wgHooks;
$wgHooks['ArticleDeleteComplete'][] = 'sbwDeleteUIDOnPageDeletion';

/**
 * When a UID page is deleted, remove the corresponding row from the
 * UID table.
 */
function sbwDeleteUIDOnPageDeletion(&$article, &$user, $reason, $id) {
  global $wgRequest, $wgOut;

  $title = $article->mTitle;

  // only try to delete if it's an actual UID
  if (sbwfVerifyUID($title)) {
    sbwfDeleteUID($title);
  }

  return true;
}
