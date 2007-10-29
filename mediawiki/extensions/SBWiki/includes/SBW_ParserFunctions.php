<?php

global $wgParser, $wgHooks;
$wgParser->setFunctionHook( 'sbwuidannot', 'sbwParserFunctionUIDAnnot' );

//error_log(print_r(array('after'=>$wgHooks),true),3,'/tmp/sbwiki_debug');


/*
class Foo {
  function sbwuidannot(&$parser) {
    return '[[LALA|this is lala]]';
  }
}


$foo = new Foo;
*/
//$wgParser->setFunctionHook( 'sbwuidcategorize', array(&$foo, 'sbwuidannot'));



function sbwParserFunctionUIDAnnot(&$parser) {

  $title = $parser->mTitle->getText();
  $uid_parts = sbwfParseUID($title);

  //debug(array('parser'=>$parser,'title'=>$title,'uid_parts'=>$uid_parts,'annot'=>$uid_parts[3]));
  return $uid_parts[3];

  return 'LALA';
}



?>
