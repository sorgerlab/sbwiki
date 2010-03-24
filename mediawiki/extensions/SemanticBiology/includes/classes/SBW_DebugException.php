<?php

/**
 * Exception class which dumps a variable or data structure to HTML,
 * along with an optional message, and does not produce a backtrace.
 */
class SBWDebugException extends FatalError {
  protected $variable;

  function __construct($variable, $message = null) {
    parent::__construct($message);
    $this->variable = $variable;
  }

  function getHTML() {
    return $this->getMessage() . '<br><br><br><br><br><br><pre>' . print_r($this->variable, true) . '</pre>';
  }

  function getText() {
    // is this enough to convert print_r's html output to ascii? (untested)
    $dump = print_r($variable, true);
    $dump = strtr($dump, "<br>", "\n");
    return $this->getMessage() . "\n\n" . $dump;
  }
}

?>