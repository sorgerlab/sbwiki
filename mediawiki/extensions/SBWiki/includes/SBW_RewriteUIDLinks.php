<?php
global $wgHooks;
$wgHooks['ParserAfterTidy'][] = 'sbwRewriteUIDLinks';

/**
 * Rewrite wiki links to UID pages such that they display as just the
 * annotation (the last part of the UID string).  Will leave links
 * alone if they have display text that's something other than the
 * UID, so links like [[XX-YYY-ZZZ-foo|blah]] will be skipped.
 *
 * If you want to override this filter and cause a UID link to display
 * as the full UID, insert a space in the link text,
 * e.g. [[XX-YY-ZZZ-foo| XX-YY-ZZZ-foo]]. (See the 'UID List' special
 * page, SBW_ListUIDs.php, for an example of this)
 */
function sbwRewriteUIDLinks($obj, $text) {
  global $wgRequest;
  $fname = 'sbwRewriteUIDLinks';

  $db =& wfGetDB( DB_SLAVE );
  $table_name = $db->tableName('sbw_uid');
  $select_vars = array('id');
  $condition_vars = array('type_code', 'creator_initials', 'id');

  // loop over links whose text looks like a UID
  $offset = 0;
  while ( preg_match('/>([A-Z]+-[A-Z]+-\d+(-[^|]*?)?)</', $text, $matches,
                     PREG_OFFSET_CAPTURE, $offset) ) {
    $uid_text  = $matches[1][0];
    $uid_start = $matches[1][1];

    $uid_parts = explode('-', $uid_text, 4);
    // grab the annotation for later use, and remove it from the parts array
    // because we aren't searching the db with it at the moment (FIXME: avoids
    // a space-vs-underscore issue that I haven't tracked down yet...
    list($annotation) = array_splice($uid_parts, 3, 1);

    // check the db table to make sure this is a legitimate UID
    $select_conds = array_combine($condition_vars, $uid_parts);  // keys => values
    $res = $db->selectRow( $table_name, $select_vars, $select_conds ); // sanitizes values automatically

    // if the lookup succeeded and there is an annotation, replace the link
    // text with the annotation
    if ( $res and strlen($annotation) ) {
      $text = substr_replace($text, "$annotation", $uid_start, strlen($uid_text));
    }

    // start the next match after this link (the true end of the link is a bit
    // farther on, but this is sufficient to get the regex to do its thing)
    $offset = $uid_start + strlen($uid_text);
  }

  return true; // always return true, in order not to stop MW's hook processing!
}
?>
