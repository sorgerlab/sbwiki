<?php
global $wgHooks;
$wgHooks[ 'SkinTemplateTabs' ][] = 'sbwCreateObjectTab';

/**
 * Adds an action that uses the default form for a category and its
 * type code to seed the add-data-with-uid form.
 * Based on sffFormEditTab from SemanticForms.
 */
function sbwCreateObjectTab($obj, $content_actions) {
  $fname = 'sbwCreateObjectTab';
  $db =& wfGetDB( DB_SLAVE );
  // make sure that this is a category page
  if (($obj->mTitle != null) && ($obj->mTitle->getNamespace() == NS_CATEGORY)) {
    $default_form_relation = str_replace(' ', '_', wfMsg('sf_form_relation'));
    $sql = "SELECT DISTINCT object_title FROM smw_relations WHERE subject_title = '" . $obj->mTitle->getText . "' AND subject_namespace = '" . NS_CATEGORY . "' AND relation_title = '$default_form_relation' AND object_namespace = " . SF_NS_FORM;
    $res = $db->query( $sql );
    if ($db->numRows( $res ) > 0) {
      while ($row = $db->fetchRow($res)) {
        // stop at the first form name we encounter
        $form_name = $row[0];
        $page = SpecialPage::getPage('AddDataUID');
        // create the target string - why doesn't getPartialURL() already
        // include the namespace? Instead, we have to add it manually
        $namespace = wfUrlencode( $obj->mTitle->getNsText() );
        if ( '' != $namespace ) {
          $namespace .= ':';
        }
        $target_name = $namespace . $obj->mTitle->getPartialURL();
        
        $content_actions['create_object'] = array(
          'class' => false,
          'text' => wfMsg('create_object'),
          'href' => $page->getTitle()->getFullURL("form=" . $form_name . "&target=" . $target_name)
        );
        $db->freeResult($res);
        return true;
      }
    }
  }
  return true; // always return true, in order not to stop MW's hook processing!
}
?>
