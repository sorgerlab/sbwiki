<?php

global $sbwgContent;
$sbwgContent = array(
  'property' => array(
    'initials' => "A user's initials.  Used to create SUID page titles.  Its type is [[has type::type:string|string]].",
  ),
  'template' => array(
    'categoryhelper table end' => '<noinclude>Used as a final, hidden template to close out infoboxes.</noinclude><includeonly>|}</includeonly>',
    'import generated content' => '<noinclude>Used to provide a hidden form field where SBWiki importer tools can place automatically generated content.</noinclude><includeonly>{{{content|}}}</includeonly>',
    '!'                        => '<noinclude>Workaround for using tables in templates.</noinclude><includeonly>|</includeonly>',
  ),
  'file' => array(
    'SemanticBiology_Add.png'     => "Add button",
    'SemanticBiology_Warning.png' => "Warning icon",
  ),
);

function sbwfCreateContent() {
  global $wgOut, $sbwgIP, $sbwgContent;

  $error = 0;

  $comment = "SemanticBiology initialization";

  $wgOut->addHTML("<h3>Creating semantic properties</h3><table>");
  while ( list($title, $content) = each($sbwgContent['property']) ) {
    $title = Title::newFromText($title, SMW_NS_PROPERTY);
    $wgOut->addHTML("<tr><td>$title</td><td>-</td>");
    $article = new Article($title);
    if ( $article->getContent() == $content ) {
      $wgOut->addHTML("<td>OK</td><td>already exists</td>");
    } else {
      $result = $article->doEdit($content, $comment);
      if ( $result->isOK() ) {
        $wgOut->addHTML("<td>OK</td><td>created</td>");
      } else {
        $wgOut->addHTML("<td>ERROR</td><td>" . $wgOut->parse($result->getWikiText()) . "</td>");
        $error = 1;
      }
    }
    $wgOut->addHTML("</tr>");
  }
  $wgOut->addHTML("</table>");
  
  $wgOut->addHTML("<h3>Creating templates</h3><table>");
  while ( list($title, $content) = each($sbwgContent['template']) ) {
    $title = Title::newFromText($title, NS_TEMPLATE);
    $wgOut->addHTML("<tr><td>$title</td><td>-</td>");
    $article = new Article($title);
    if ( $article->getContent() == $content ) {
      $wgOut->addHTML("<td>OK</td><td>already exists</td>");
    } else {
      $result = $article->doEdit($content, $comment);
      if ( $result->isOK() ) {
        $wgOut->addHTML("<td>OK</td><td>created</td>");
      } else {
        $wgOut->addHTML("<td>ERROR</td><td>" . $wgOut->parse($result->getWikiText()) . "</td>");
        $error = 1;
      }
    }
    $wgOut->addHTML("</tr>");
  }
  $wgOut->addHTML("</table>");

  $wgOut->addHTML("<h3>Uploading images</h3><table>");
  while ( list($title, $content) = each($sbwgContent['file']) ) {
    $path = $sbwgIP . '/assets/' . $title;
    $title = Title::newFromText($title, NS_FILE);
    $wgOut->addHTML("<tr><td>$title</td><td>-</td>");
    $article = new ImagePage($title);
    $correct_hash = File::sha1Base36($path);
    if ( $article->getContent() == $content and $article->getFile() and $article->getFile()->getSha1() == $correct_hash ) {
      $wgOut->addHTML("<td>OK</td><td>already exists</td>");
    } else {
      $upload = new UploadFromFile();
      # copy file to temp dir since performUpload removes the source file!
      $tmppath = tempnam(null, null);
      copy($path, $tmppath);
      clearstatcache();  # otherwise filesize will report 0
      $upload->initialize($title->getText(), $tmppath, filesize($tmppath));
      $upload->verifyUpload();  # initializes mFileProps so performUpload doesn't complain
      $result = $upload->performUpload($comment, $content, false, null);
      if ( $result->isOK() ) {
        $wgOut->addHTML("<td>OK</td><td>created</td>");
      } else {
        $wgOut->addHTML("<td>ERROR</td><td>" . $wgOut->parse($result->getWikiText()) . "</td>");
        $error = 1;
      }
    }
    $wgOut->addHTML("</tr>");
  }
  $wgOut->addHTML("</table>");

  if ( !$error ) {
    $wgOut->addHTML("<h3>Success!</h3>");
  } else {
    $wgOut->addHTML("<h3>There were some errors, see above for details.</h3>");    
  }

  return !$error;
}

?>
