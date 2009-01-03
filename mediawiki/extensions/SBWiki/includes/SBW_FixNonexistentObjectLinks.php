<?php
global $wgHooks;
$wgHooks['ArticleInsertComplete'][] = 'sbwFixNonexistentObjectLinks';

/**
 * This hook supports the feature where properties with a type of Page
 * (OWL ObjectProperties) can be entered as free text not linking to
 * an existing UID page (individual), but clicking on the red link
 * later on to create the page will still properly follow the UID
 * creation process and also fix up the existing links.
 *
 * This hook implements the post-save 'fix up' phase.
 */
function sbwFixNonexistentObjectLinks(&$article, &$user, &$text, &$summary, &$minoredit, 
				      &$watchthis, &$sectionanchor, &$flags, &$revision) {
  global $wgRequest, $wgOut;

  // abort if the title isn't a UID
  if (!sbwfVerifyUID($article->mTitle)) return true;

  // get the UID's annotation field which is the "old title" we'll be searching for
  $new_title = $article->mTitle->getText();
  $uid_parts = sbwfParseUID($new_title);
  $old_title = $uid_parts[3];

  // find properties for which the old title is the object
  $article = SMWDataValueFactory::newTypeIDValue('_wpg', $old_title);
  $properties = smwfGetStore()->getInProperties($article); // returns Titles

  // fix up the subject pages implicated in the previous step
  $old_title_match = '[' . preg_quote(strtoupper($old_title[0]) . strtolower($old_title[0])) . ']' . preg_quote(substr($old_title, 1));
  $old_title_match = preg_replace('/_/', '[_ ]', $old_title_match);
  $new_title_replace = "\$1$new_title";
  foreach ($properties as $property) {
    $property_match = preg_quote(strtolower($property->getText()), '/');
    $subjects = smwfGetStore()->getPropertySubjects($property, $article); // also returns Titles
    foreach ($subjects as $subject) {
      $article_text = Revision::newFromTitle($subject)->revText();
      // WIP 2009/01/02 debug this regex
      $template_match = "/({{Property $property_match\\s*\\|\\w+=)$old_title_match/";
      error_log($template_match);
      preg_replace($template_match, $new_title, $article_text);
      error_log($article_text);
    }
  }

  return true;
}
