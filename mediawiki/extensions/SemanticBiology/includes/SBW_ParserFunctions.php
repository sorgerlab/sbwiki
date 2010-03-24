<?php

global $wgParser, $wgHooks;
$wgParser->setFunctionHook( 'filesize', 'sbwParserFunctionFileSize' );
//$wgParser->setFunctionHook( 'sbwuidcategorize', array(&$foo, 'sbwuidannot'));



function sbwParserFunctionFileSize(&$parser, $filename, $include_pretty=null) {
  $file = Image::newFromName($filename);
  if ( !$file ) return null;

  $size = $file->getSize();

  // if $include_pretty is set, append wiki link display text
  //   consisting of size in largest reasonable unit (B, KB, MB)
  // FIXME: more cleanly done with a table and iteration
  if ( $include_pretty ) {
    $display_size = $size;
    $unit = 'B';
    if ( $display_size >= 1024 ) {
      $display_size /= 1024;
      $unit = 'KB';
      if ( $display_size >= 1024 ) {
        $display_size /= 1024;
        $unit = 'MB';
      }
      $display_size = sprintf('%.1f', $display_size); // round to 1 decimal place
    }
    $size = "$size|$display_size $unit";
  }

  return $size;
}


function sbwParserFunctionUIDAnnot(&$parser) {
  $title = $parser->mTitle->getText();
  $uid_parts = sbwfParseUID($title);
  $annotation = strtr($uid_parts[3], '_', ' ');

  return $annotation;
}



?>
