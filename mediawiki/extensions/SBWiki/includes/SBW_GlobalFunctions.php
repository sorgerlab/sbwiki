<?php
/**
 * Global functions and constants for SBW
 */

define('SBW_VERSION','0.0.1');

$wgExtensionFunctions[] = 'sbwgSetupExtension';
#TEMP $wgHooks['LanguageGetMagic'][] = 'sbwParserFunctionsLGM';

function sbwParserFunctionsLGM( &$magicWords, $langCode ) {
  $magicWords['sbwuidcategorize'] = array( 0, 'sbwuidcategorize' );
  //error_log(print_r($magicWords,true),3,'/tmp/sbwiki_debug');
  return true;
}

/**
 *  Do the actual intialisation of the extension. This is just a delayed init that makes sure
 *  MediaWiki is set up properly before we add our stuff.
 */
function sbwgSetupExtension() {
  global $sbwgIP, $wgHooks, $wgExtensionCredits, $wgArticlePath, $wgScriptPath, $wgServer;

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

#TEMP  require_once($sbwgIP . '/includes/SBW_ParserFunctions.php');
  require_once($sbwgIP . '/includes/SBW_CreateObjectTab.php');
  require_once($sbwgIP . '/includes/SBW_RewriteUIDLinks.php');
  
  /**********************************************/
  /***** credits (see "Special:Version")    *****/
  /**********************************************/
  $wgExtensionCredits['other'][]= array('name'=>'Systems Biology Wiki',
                                        'version'=>SBW_VERSION,
                                        'author'=>'Jeremy Muhlich',
                                        'description' => 'TODO');

  sbwfSetupMessages();

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
function sbwfFormatUID($type_code, $creator_initials, $id, $annotation = NULL) {
  $parts = array($type_code, $creator_initials, $id);
  if ( $annotation != NULL and $annotation != '' ) {
    array_push($parts, $annotation);
  }
  $uid = join('-', $parts);

  return $uid;
}


/*
 * Splits a UID string into its four parts
 */
function sbwfParseUID($uid) {
  $uid_parts = explode('-', $uid, 4);
  count($uid_parts) == 4 or $uid_parts[3] = null;

  return $uid_parts;
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

  $insert_values = array('type_code'        => $type_code,
                         'creator_initials' => $creator_initials);
  $annotation = strtr($annotation, ' ', '_'); // normalize space to underscore
  if ( $annotation != '' ) {
    $insert_values['annotation'] = $annotation;
  }

  $db =& wfGetDB(DB_MASTER);
  $db->insert($db->tableName('sbw_uid'), $insert_values, $fname);
  $result = $db->select($db->tableName('sbw_uid'),
                        'id,type_code,creator_initials,annotation',
                        'id = last_insert_id()',
                        $fname);
  $row = $db->fetchRow($result);

  $page_title = sbwfRowToUID($row);

  // FIXME should this return a Title object?  Does that work if the page doesn't exist?
  return $page_title;
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
    // FIXME: this just retrieves the first attribute, not specifically the Initials!  and it should maybe use the Query API instead.
    $result = $db->select($db->tableName('smw_attributes'),
                          'value_xsd',
                          'subject_id='. $wgUser->getUserPage()->getArticleID(),
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


function debug($object) {
  global $wgOut;

  $wgOut->addHTML('<pre style="color:#f00;">'.htmlspecialchars(print_r($object,true)).'</pre>');
}

?>
