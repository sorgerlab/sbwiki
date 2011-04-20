<?php

class SBWCategoryTree {

  private $entries = array();
  private $dbr;

  function __construct(&$title) {
    $this->dbr = wfGetDB(DB_SLAVE);
    $this->collectChildren($title);
  }

  function collectChildren(&$title, $depth=0) {
    $entry = new SBWCategoryTreeEntry($title, $depth);
    array_push($this->entries, $entry);

    $ctWhere = ' cl_to = ' . $this->dbr->addQuotes($title->getDBkey());
    $nsmatch = ' AND cat.page_namespace = ' . NS_CATEGORY;
    $page = $this->dbr->tableName('page');
    $categorylinks = $this->dbr->tableName('categorylinks');
    $sql = "SELECT cat.page_namespace, cat.page_title,
				cl_to, cl_from
				FROM $page as cat
				JOIN $categorylinks ON cl_from = cat.page_id 
				WHERE $ctWhere
				$nsmatch
				ORDER BY cl_sortkey";
    $res = $this->dbr->query($sql, __METHOD__);

    while ( $row = $this->dbr->fetchObject($res) ) {
      $t = Title::newFromRow($row);
      $this->collectChildren($t, $depth + 1);
    }

    $this->dbr->freeResult($res);
  }

  function getEntries() {
    return $this->entries;
  }

}


class SBWCategoryTreeEntry {
  public $depth;
  public $title;

  function __construct(&$title, $depth) {
    $this->title = $title;
    $this->depth = $depth;
  }
}