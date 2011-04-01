<?php

/*
  TODO:

  * Initialization function
  ** "upload" SemanticBiology_*.png from assets dir
  ** create 'initials' property (type:string)

*/

if (!defined('MEDIAWIKI')) die();

global $IP, $sbwgMIP;
require_once( "$IP/includes/SpecialPage.php" );
require_once( "$sbwgMIP/SBW_initdatabase.php" );
require_once( "$sbwgMIP/SBW_createcontent.php" );

SpecialPage::addPage( new SpecialPage('SBWAdmin','',true,'doSpecialSBWAdmin',false) );


function doSpecialSBWAdmin()
{
  global $wgOut, $wgRequest;

  if ( $wgRequest->wasPosted() ) {

    switch ( $wgRequest->getText('action') ) {
    case 'db_init':
      $result = sbwfInitDatabase();
      break;
    case 'create_content':
      $result = sbwfCreateContent();
      break;
    }
    if ( !$result ) {
      $wgOut->addHTML("<p style=\"font-size: 150%;\">There was a problem performing this action.  Please try again.</p>");
    }
    $wgOut->addHTML("<p><a href=\"\">Return to SBW Admin page</a></p>");

  } else {

    $wgOut->addHTML(<<<HTML
<form method="POST">

<h2>Database installation and upgrade</h2>

<p>Semantic Biology requires some extensions to the MediaWiki database in order to store some
internal data.  The below function ensures that your database is set up properly. The changes
made in this step do not affect the rest of the MediaWiki database, and can easily be undone if
desired. This setup function can be executed multiple times without doing any harm, but it is
needed only once on installation or upgrade.</p>

<p>If the operation fails with SQL errors, the database user employed by your wiki (check your
LocalSettings.php) probably does not have sufficient permissions. Either grant this user
additional pemissions to create and delete tables, temporarily enter the login of your database
root in LocalSettings.php, or use the maintenance script sbw_initdatabase.php which can use the
credentials of AdminSettings.php.</p>

<input type="submit" value="Initialize tables" />
<input name="action" type="hidden" value="db_init" />

</form>


<form method="POST">

<h2>Content creation</h2>

<p>Semantic Biology requires some predefined wiki content to be in place to support some of its
features.  This content includes templates, semantic properties, and images.  The below function
ensures that all of this content is properly created.  It will not affect the rest of your wiki
content and is safe to run and can be executed multiple times without doing any harm,</p>

<input type="submit" value="Create content" />
<input name="action" type="hidden" value="create_content" />

</form>


HTML
                    );

  }

}
