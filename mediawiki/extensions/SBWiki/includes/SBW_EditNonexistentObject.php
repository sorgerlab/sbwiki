<?php
global $wgHooks;
$wgHooks['AlternateEdit'][]         = 'sbwEditNonexistentObject';
$wgHooks['ArticleInsertComplete'][] = 'sbwFixNonexistentObjectLinks';

/**
 * These hooks support the feature where properties with a type of
 * Page (OWL ObjectProperties) can be entered as free text not linking
 * to an existing UID page (individual), but clicking on the red link
 * later on to create the page will still properly follow the UID
 * creation process and also fix up the existing links.
 */


/**
 * This hook implements the UID creation when someone edits the
 * nonexistent page.
 *
 * We do this by intercepting edit requests and checking for the
 * following conditions: 1) the page does not exist; 2) the title is
 * not already a registered UID; 3) the page is the object of some
 * relation; 4) the property has a range which is a class in the
 * ontology.  If all these are true, redirect the user to the UID
 * creation page.  The user will subsequently be redirected back to
 * the edit page of course, but at that point a UID will have been
 * allocated so condition #2 will be false.
 */
function sbwEditNonexistentObject(&$editpage) {
  global $wgRequest, $wgOut;
  $fname = 'sbwEditNonexistentObject';

  // does page exist? if so, abort
  $title = $editpage->mTitle;
  if ($title->exists()) return true;

  // is the title already a UID? if so, abort
  if (sbwfVerifyUID($title)) return true;

  // is the page some relation's object? if not, abort
  $article = SMWDataValueFactory::newTypeIDValue('_wpg', $title);
  $properties = smwfGetStore()->getInProperties($article); // returns Titles
  if (!$properties) return true;

  // do any of the properties have a range that's a subclass of
  // "SBWiki thing"? if not, abort
  // FIXME: harcoding the ancestor class is lame; maybe there's a
  //   cleaner way to handle that.  A config option maybe?  The contents of
  //   a special page?
  // FIXME: we just check the first property for now and hope for the best
  $property = $properties[0];
  $query = "[[$property]] [[Has range hint:: <q>[[:Category:+]] [[Category:SBWiki thing]]</q> ]]";
  $printouts = array('?Has range hint');
  $result = sbwfSemanticQuery($query, $printouts);
  if (!$result->getCount()) return true;

  $row = $result->getNext();
  $value = $row[0]->getContent();
  $range_category = $value[0]->getTitle();

  $redirect_title = Title::makeTitle(NS_SPECIAL, 'AddDataUID');
  $url_params = "root_category=$range_category&annotation=$title";
  $wgOut->redirect($redirect_title->getFullURL($url_params));

  return false; // stop processing, since we already redirected
}


/*
 * This hook implements the post-save 'fix up' phase.
 *
 * It's triggered when a new article is successfully saved.
 */
function sbwFixNonexistentObjectLinks(&$article, &$user, &$text, &$summary, &$minoredit, 
				      &$watchthis, &$sectionanchor, &$flags, &$revision) {
  global $wgRequest, $wgOut;

  // abort if the title isn't a UID
  if (!sbwfVerifyUID($article->mTitle)) return true;

  // get the UID's annotation field which is the "old title" we'll be searching for
  $new_title = $article->mTitle->getText();
  $uid_parts = sbwfParseUID($new_title, true);
  $old_title = $uid_parts['annotation'];

  // find properties for which the old title is the object
  $article = SMWDataValueFactory::newTypeIDValue('_wpg', $old_title);
  $properties = smwfGetStore()->getInProperties($article); // returns some internal SMW Title-like objects

  // fix up the subject pages implicated in the previous step
  $error_pages = array();
  $rev_id = $revision->getId();
  // need to deal with normalized form of $old_title
  $old_title_match = '[' . preg_quote(strtoupper($old_title[0]) . strtolower($old_title[0])) . ']' . preg_quote(substr($old_title, 1));
  $old_title_match = preg_replace('/_/', '[_ ]', $old_title_match);
  $new_title_replace = "\$1$new_title\$2"; // see $template_match to understand $1/$2
  foreach ($properties as $property) {
    $property_match = preg_quote(strtolower($property->getText()), '/');  // property is lower case in our template name
    $template_match = "/({{Property $property_match\\s*\\|\\w+=)$old_title_match(\\s+)/";
    $subjects = smwfGetStore()->getPropertySubjects($property, $article); // returns SMW Title-like objects
    foreach ($subjects as $subject) {
      // grab article text and modify it
      $subject_title = $subject->getTitle();
      $subject_article_text = Revision::newFromTitle($subject_title)->revText();
      $subject_article_text = preg_replace($template_match, $new_title_replace, $subject_article_text);
      // save modified text back to article
      $subject_article = new Article($subject_title);
      $result = $subject_article->doEdit($subject_article_text, "automatically changed '$old_title' to '$new_title' to reflect new UID creation at [[$new_title]] (revision $rev_id)",
					 EDIT_UPDATE | EDIT_MINOR | EDIT_SUPPRESS_RC);
      if (!$result) $error_pages[] = $subject_title->getText();
    }
  }

  if ($error_pages) {
    debug("Could not make edits on the following pages to change '$old_title' to '$new_title': " . join(", ", $error_pages));
  }

  return true;
}
