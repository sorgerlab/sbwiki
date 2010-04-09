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
function sbwRewriteUIDLinks(&$parser, &$text) {
  global $wgRequest, $sbwgUIDPattern;

  // loop over links whose text looks like a UID
  $offset = 0;
  // FIXME: this matches text after *any* tag, and also the Special:Browse link at the top of the SMW factbox
  // FIXME: this has a dependence on the UID format, which we would like to avoid
  while ( preg_match("/<a [^>]*?title=\"$sbwgUIDPattern\"[^>]*?>($sbwgUIDPattern)<\/a>/S",
		     $text, $matches, PREG_OFFSET_CAPTURE, $offset) ) {
    $uid_text  = $matches[5][0];
    $uid_start = $matches[5][1];

    // see if this is a legitimage UID
    $uid_parts = sbwfVerifyUID($uid_text, true);

    // if the lookup succeeded, replace the link text with the annotation
    $annotation = ''; // initialize so that $offset calculation won't cause an error
    if ( $uid_parts ) {
      $annotation = strtr($uid_parts['annotation'], '_', ' ');
      $text = substr_replace($text, $annotation, $uid_start, strlen($uid_text));
    }

    // start the next match precisely after this matched <a> tag
    $offset = $matches[0][1] + strlen($matches[0][0]) - (strlen($uid_text) - strlen($annotation));
  }

  return true; // always return true, in order not to stop MW's hook processing!
}
?>
