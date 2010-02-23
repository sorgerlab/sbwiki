<?php
/**
 * Global functions and constants for SBW
 */

define('SBW_VERSION','0.0.1');

$wgExtensionFunctions[] = 'sbwgSetupExtension';
$wgHooks['LanguageGetMagic'][] = 'sbwLanguageGetMagic';

$sbwgUIDPattern = null;  // initialized in sbwgSetupExtention, once Title has been loaded


function sbwLanguageGetMagic( &$magicWords, $langCode ) {
  // FIXME: this ignores $langCode since we only offer English anyway

  $magicWords['filesize'] = array( 0, 'filesize' );

  return true;
}


/**
 *  Do the actual intialisation of the extension. This is just a delayed init that makes sure
 *  MediaWiki is set up properly before we add our stuff.
 */
function sbwgSetupExtension() {
  global $sbwgIP, $sbwgUIDPattern, $wgHooks, $wgExtensionCredits, $wgArticlePath,
    $wgScriptPath, $wgServer;

  /**********************************************/
  /***** register specials                  *****/
  /**********************************************/
  require_once($sbwgIP . '/specials/SBW_AddDataUID.php');
  require_once($sbwgIP . '/specials/SBW_GenerateUIDList.php');
  require_once($sbwgIP . '/specials/SBW_ImportModel.php');
  require_once($sbwgIP . '/specials/SBW_ListUIDs.php');
  require_once($sbwgIP . '/specials/SBW_API.php');
  require_once($sbwgIP . '/specials/SBW_UploadAttachFileUID.php');

  /**********************************************/
  /***** register hooks                     *****/
  /**********************************************/
  require_once($sbwgIP . '/includes/SBW_ParserFunctions.php');
  require_once($sbwgIP . '/includes/SBW_RewriteUIDLinks.php');
  require_once($sbwgIP . '/includes/SBW_EditNonexistentObject.php');
  require_once($sbwgIP . '/includes/SBW_DeleteUIDOnPageDeletion.php');
  
  /**********************************************/
  /***** common classes                     *****/
  /**********************************************/
  require_once($sbwgIP . '/includes/classes/SBW_DebugException.php');

  /**********************************************/
  /***** credits (see "Special:Version")    *****/
  /**********************************************/
  $wgExtensionCredits['other'][]= array('name'=>'Systems Biology Wiki',
                                        'version'=>SBW_VERSION,
                                        'author'=>'Jeremy Muhlich',
                                        'description' => 'TODO');

  sbwfSetupMessages();

  // includes < in final char group to avoid matching closing html tags in certain uses
  $sbwgUIDPattern = '([' . Title::legalChars() . ']+?)\.([^0-9]+)([0-9]+)([^0-9<]+)';

  return true;
}

/**********************************************/
/***** other global helpers               *****/
/**********************************************/

/**
 * Set up message cache
 */
function sbwfSetupMessages() {
  global $wgMessageCache;

  $messages = array(
                    'adddatauid'          => 'Add data with UID',
                    'generateuidlist'     => 'Generate several UIDs at once',
                    'importmodel'         => 'Import SBML Model',
                    'listuids'            => 'UID List',
                    'sbw_api'             => 'SBwiki API endpoint',
                    'uploadattachfileuid' => 'Upload file content for a UID',
                    );

  $wgMessageCache->addMessages($messages);
}


/*
 * Assembles a UID string from its four parts
 */
function sbwfFormatUID($type_code, $creator_initials, $id, $annotation) {
  $annotation = strtr($annotation, ' ', '_'); // normalize space to underscore
  $uid = "$annotation.$type_code$id$creator_initials";

  return $uid;
}


/*
 * Splits a UID string into its four parts
 */
function sbwfParseUID($uid, $want_hash=false) {
  global $sbwgUIDPattern;

  $result = preg_match("/^$sbwgUIDPattern$/", $uid, $uid_parts);
  if (!$result) {
    return null;
  }
  array_splice($uid_parts, 0, 1); // remove first element, the entire match
  $uid_parts[0] = strtr($uid_parts[0], ' ', '_'); // normalize space to underscore

  if ($want_hash) {
    return array_combine(array('annotation', 'type_code', 'id', 'creator_initials'), $uid_parts);
  } else {
    return $uid_parts;
  }
}


/*
 * Assembles a UID string from a db record (as returned by fetchRow())
 */
function sbwfRowToUID($row) {
  return sbwfFormatUID($row['type_code'], $row['creator_initials'], $row['id'], $row['annotation']);
}


/**
 * Creates a record in the UID table and returns the properly formatted page title
 */
function sbwfAllocateUID($type_code, $creator_initials, $annotation) {
  $fname = 'SBW::sbwfAllocateUID';

  // FIXME add full page title (or probably just a link to the 'page' table)
  // FIXME pre-validate page title to ensure no bad characters (use Title::newFromText)
  $annotation = strtr($annotation, ' ', '_'); // normalize space to underscore
  $insert_values = array('type_code'        => $type_code,
                         'creator_initials' => $creator_initials,
			 'annotation'       => $annotation);

  $db =& wfGetDB(DB_MASTER);
  $db->insert($db->tableName('sbw_uid'), $insert_values, $fname);
  $result = $db->select($db->tableName('sbw_uid'),
                        'id,type_code,creator_initials,annotation',
                        'id = last_insert_id()',
                        $fname);
  $row = $db->fetchRow($result);

  $page_title = sbwfRowToUID($row);

  // FIXME should this return a Title object?  Does that work if the
  // page doesn't exist? (Yes, call Title::newFromText())
  return $page_title;
}


/**
 * Deletes a record from the UID table
 */
function sbwfDeleteUID($uid) {
  $fname = 'SBW::sbwfDeleteUID';

  $uid_parts = sbwfParseUID($uid, true);
  if ($uid_parts) {
    $db =& wfGetDB(DB_MASTER);
    $db->delete($db->tableName('sbw_uid'), $uid_parts, $fname);
  } else {
    die("Invalid or empty UID: '$uid'");
  }
}


/**
 * Checks whether a given string is registered as a UID
 */
function sbwfVerifyUID($uid, $want_hash=false) {
  $fname = 'SBW::sbwfVerifyUID';

  $uid_parts = sbwfParseUID($uid);
  if ($uid_parts) {
    // make sure this isn't just something that *looks* like a UID
    $db =& wfGetDB(DB_MASTER);
    $columns = array('annotation', 'type_code', 'id', 'creator_initials');
    $uid_hash = array_combine($columns, $uid_parts);
    $result = $db->select($db->tableName('sbw_uid'),
			  'id', $uid_hash, $fname);
    $row = $db->fetchRow($result);
    
    if ($want_hash) {
      $ret = $row ? array_combine($columns, $uid_parts) : null;
    } else {
      // force return to be a boolean value
      $ret = $row ? true : false;
    }
  } else {
    $ret = false;
  }

  return $ret;
}


/**
 * Fetches a user's initials
 */
function sbwfGetUserInitials() {
  global $wgUser;
  $fname = 'SBW::sbwfGetUserInitials';

  $initials = null;

  if ( User::isValidUserName($wgUser->getName()) ) {

    $db =& wfGetDB(DB_SLAVE);
    // FIXME: this just retrieves the first attribute, not specifically the Initials!  and it should definitely use the Query API instead.
    $result = $db->select(array($db->tableName('smw_atts2'),$db->tableName('smw_ids')),
                          'value_xsd',
                          array('s_id=smw_id', 'smw_namespace='.NS_USER, 'smw_title='.$db->addQuotes($wgUser->getUserPage()->getText())),
                          $fname);
    $row = $db->fetchRow($result);
    $initials = $row[0];
  }

  return $initials;
}


/**
 * Returns a list of UIDs, optionally limited by some criteria
 */
// TODO: implement search criteria
function sbwfListUIDs() {
  global $wgOut;
  $fname = 'SBW::sbwfListUIDs';

  $select_vars  = array('id','type_code','creator_initials','annotation');
  $select_conds = array();

  $db =& wfGetDB(DB_SLAVE);
  $result = $db->select($db->tableName('sbw_uid'), $select_vars, $select_conds, $fname);  

  $uids = array();
  while ( $row = $db->fetchRow($result) ) {
    array_push($uids, sbwfRowToUID($row));
  }

  return $uids;
}


/**
 * Gets the information needed by AddDataUID to create a UID in a
 * given category: the name of its default form and its abbreviation.
 * On error, returns an error message as the third value.  FIXME:
 * error behavior is kind of dumb. maybe throw an exception?  The
 * $category input parameter and the first return parameter are Title
 * objects.
 */
function sbwfGetCategoryCreateInfo($category) {
  $query = "[[:$category]]";
  $printouts = array('?Has default form', '?Abbreviation');
  $result = sbwfSemanticQuery($query, $printouts);
  // expect just one row since the query is for one explicit category itself
  $row = $result->getNext();

  // extract value for 'has default form' (column 0)
  $form_content = $row[0]->getContent();
  // take value 0 (can be multiple values per column!)
  $form = count($form_content) ? $form_content[0]->getTitle() : null;

  // extract value for 'abbreviation' (column 1)
  $abbreviation_content = $row[1]->getContent();
  $abbreviation = count($abbreviation_content) ? $abbreviation_content[0]->getXSDValue() : null;

  return array($form, $abbreviation);
}


/**
 * Just like it says on the tin.  Returns an array of Title objects.
 */
function sbwfGetSubcategories($category) {
  $query = "[[$category]] [[:Category:+]]";
  $result = sbwfSemanticQuery($query);
  $subcategories = array();
  while ( $row = $result->getNext() ) {
    $value = $row[0]->getContent();
    array_push($subcategories, $value[0]->getTitle());
  }

  return $subcategories;
}

/**
 * There is no nice API to the SMW query engine that supports
 * "printouts" (the equivalent of the projection component of a SQL
 * statement) so I wrote one.  Input params are 1) a query (i.e. the
 * contents of the left textarea in Special:Ask) and 2) an array of
 * printouts/args (the contents of the right textarea, with each line
 * in its own array element).  In fact, this function emulates the
 * same code path as Special:Ask, with as much code reuse as possible.
 * The return is an SMWQueryResult which is a pretty hairy structure.
 * See sbwfGetCategoryCreateInfo for sample usage and result parsing.
 *
 * TODO: wrap the result in some nicer structure (with less power but
 * far simpler usage)
 */
function sbwfSemanticQuery($query_in, $printouts_in = array()) {
  $rawparams = array_merge((array)$query_in, $printouts_in);
  $querystring = $params = $printouts = null;
  SMWQueryProcessor::processFunctionParams($rawparams, $querystring, $params, $printouts);
  $query  = SMWQueryProcessor::createQuery($querystring, $params, null, null, $printouts);
  $result = smwfGetStore()->getQueryResult($query);

  return $result;
}


function debug($object) {
  global $wgOut;

  $wgOut->addHTML('<pre style="color:#f00;">'.htmlspecialchars(print_r($object,true)).'</pre>');
}
