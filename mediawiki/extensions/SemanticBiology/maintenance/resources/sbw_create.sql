CREATE TABLE /*$wgDBprefix*/sbw_uid (
  id                    serial,
  type_code             char(2)         NOT NULL,
  creator_initials      char(3)         NOT NULL,
  annotation            varchar(255),

  PRIMARY KEY           id (id)
) /*$wgDBTableOptions*/;


-- Force id numbering to start at 100 (just an aesthetic choice).
--
DELETE FROM /*$wgDBprefix*/sbw_uid
  WHERE id=99;
INSERT INTO /*$wgDBprefix*/sbw_uid
  (id, type_code, creator_initials, annotation)
  VALUES (99, 'XX', 'XXX', 'dummy');
DELETE FROM /*$wgDBprefix*/sbw_uid
  WHERE id=99;
