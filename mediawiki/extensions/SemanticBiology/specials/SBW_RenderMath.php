<?php

if (!defined('MEDIAWIKI')) die();

global $IP, $sbwgIP;
require_once( "$IP/includes/SpecialPage.php" );
require_once( "$sbwgIP/includes/phpmathpublisher/mathpublisher.php" );

SpecialPage::addPage( new SpecialPage('RenderMath','',true,'doSpecialRenderMath',false) );

function doSpecialRenderMath() {
  global $wgOut, $wgRequest, $wgScriptPath;

  $mathml = $wgRequest->getVal('mathml');
  if ( !strlen($mathml) ) {
    $mathml = '<math xmlns="http://www.w3.org/1998/Math/MathML"> <apply> <divide/> <apply> <times/> <ci> default </ci> <ci> Vs </ci> <apply> <power/> <ci> KI </ci> <ci> n </ci> </apply> </apply> <apply> <plus/> <apply> <power/> <ci> KI </ci> <ci> n </ci> </apply> <apply> <power/> <ci> Pn </ci> <ci> n </ci> </apply> </apply> </apply> </math>';
  }

  $wgOut->addHTML(<<<FORM
<p>Paste MathML for rendering.</p>

<div>

<form method="post" action="$wgScriptPath/index.php/Special:RenderMath">

<table>
<tr><td><textarea name="mathml" cols="50" rows="20">$mathml</textarea></td></tr>
<tr><td><input name="submit" type="submit" value="Render MathML"></td></tr>
</table>

</form>

</div>

FORM
		  );

  $asciimath = convertMathmlToAscii($mathml);
  $wgOut->addHTML("<pre>$asciimath</pre><br/>" . mathfilter("<m>$asciimath</m>", 16, "/wiki/extensions/SemanticBiology/includes/phpmathpublisher/img/"));
}


function convertMathmlToAscii($data) {
  $mathml_parser = new MathmlParser();
  $mathml_parser->parse($data);
  return $mathml_parser->ascii;
}


class MathmlParser {
  var $xml;
  var $depth = 0;
  var $op_stack = array();

  function MathmlParser() {
    $this->xml = xml_parser_create();
    xml_set_object($this->xml, $this);
    xml_set_element_handler($this->xml, "element_start", "element_end");
    xml_set_character_data_handler($this->xml, "cdata");
  }

  function parse($data) {
    $xml = simplexml_load_string($data);
    $this->ascii = $this->recurse($xml);

    // DEBUGGING xml_parse($this->xml, $data, true);
  }

  /*
    Recursively traverses a simplexml representation of a mathml expression
   */
  function recurse($xml) {
    return call_user_func(array($this, 'handle_' . $xml->getName()), $xml);
  }

  function handle_math($xml) {
    $children = $xml->children();
    return $this->recurse($children[0]);
  }

  function handle_apply($xml) {
    $children = $xml->children();
    $op = $children[0]->getName();
    array_push($this->op_stack, $op);
    $args = array();
    for ( $i = 1; $i < count($children); $i++ ) {
      array_push($args, $children[$i]);
    }
    $need_parens = false;
    $ret = '';
    $ret .= $need_parens ? '(' : '{';
    $ret .= call_user_func(array($this, "op_$op"), $args);
    $ret .= $need_parens ? ')' : '}';
    array_pop($this->op_stack);
    return $ret;
  }

  function handle_piecewise($xml) {
    $num_pieces = count($xml->piece);
    $ret = 'delim{lbrace}{matrix{' . $num_pieces . '}{3}{';
    foreach ($xml->piece as $piece) {
      $children = $piece->children();
      $value = $this->recurse($children[0]);
      $condition = $this->recurse($children[1]);
      $ret .= "{$value}{if}{$condition}";
    }
    // using ~ (space) as right delim avoids a spurious warning from phpmathpublisher
    $ret .= '}}{~}';
    return $ret;
  }

  function handle_ci($xml) {
    return '{' . preg_replace('/\s/', '', (string) $xml) . '}';
  }

  function handle_cn($xml) {
    return $this->handle_ci($xml);
  }

  function op_plus($args) {
    $ret = implode('+', array_map(array($this, 'recurse'), $args));
    return $this->parens($ret, array('minus', 'times', 'power'));
  }

  function op_minus($args) {
    $ret = implode('-', array_map(array($this, 'recurse'), $args));
    return $this->parens($ret, array('times', 'power'));
  }

  function op_times($args) {
    $ret = implode('*', array_map(array($this, 'recurse'), $args));
    return $this->parens($ret, array('power'));
  }

  function op_divide($args) {
    $ret = $this->recurse($args[0]) . "/" . $this->recurse($args[1]);
    return $this->parens($ret, array('power'));
  }

  function op_power($args) {
    return $this->recurse($args[0]) . "^" . $this->recurse($args[1]);
  }

  function op_gt($args) {
    return $this->recurse($args[0]) . ">" . $this->recurse($args[1]);
  }

  function op_geq($args) {
    return $this->recurse($args[0]) . ">=" . $this->recurse($args[1]);
  }

  function op_lt($args) {
    return $this->recurse($args[0]) . "<" . $this->recurse($args[1]);
  }

  function op_leq($args) {
    return $this->recurse($args[0]) . "<=" . $this->recurse($args[1]);
  }

  function parens($ascii, $higher_precedence_ops) {
    $depth = count($this->op_stack);
    if ( $depth > 1 ) {
      if ( in_array($this->op_stack[$depth-2], $higher_precedence_ops) ) {
	$ascii = "($ascii)";
      }
    }
    return $ascii;
  }

  function element_start($parser, $name, $attrs) 
  {
    $out = "";
    for ($i = 0; $i < $this->depth; $i++) {
      $out .= "  ";
    }
    $out .= $name;
    debug($out);
    $this->depth++;
  }

  function element_end($parser, $name) 
  {
    $this->depth--;
  }

  function cdata($parser, $data) {
    if ( !preg_match('/\S/', $data) ) {
      return;
    }
    $out = "";
    for ($i = 0; $i < $this->depth; $i++) {
      $out .= "  ";
    }
    $out .= ">> $data <<";
    debug($out);
  }

}
