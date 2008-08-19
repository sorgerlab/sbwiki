<?php
global $wgHooks;
$wgHooks['AlternateEdit'][] = 'sbwEditNonexistentObject';

/**
 * This hook supports the feature where properties with a type of Page
 * (OWL ObjectProperties) can be entered as free text not linking to
 * an existing UID page (individual), but clicking on the red link
 * later on to create the page will still properly follow the UID
 * creation process and also fix up the existing links.
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
  if ($editpage->mTitle->exists()) return true;

  // is the title already a UID? if so, abort
  $title = $editpage->mTitle;
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
  $query_string = "[[$property]] [[Has range hint:: <q>[[:Category:+]] [[Category:SBWiki thing]]</q> ]]";
  $query = SMWQueryProcessor::createQuery($query_string, array());
  $result = smwfGetStore()->getQueryResult($query);
  if (!$result->getCount()) return true;

  $redirect_title = Title::makeTitle(NS_SPECIAL, 'AddDataUID');
  //throw new SBWDebugException($redirect_title);
  $url_params = array();
  $wgOut->redirect($redirect_title->getFullURL());

  return false; // stop processing, since we already redirected
}
?>
