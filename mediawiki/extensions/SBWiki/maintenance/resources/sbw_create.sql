CREATE TABLE /*$wgDBprefix*/sbw_uid (
  id                    bigint unsigned NOT NULL        auto_increment,
  type_code             char(2)         NOT NULL,
  creator_initials      char(3)         NOT NULL,
  annotation            varchar(255),

  PRIMARY KEY           id (id)
) /*$wgDBTableOptions*/;
