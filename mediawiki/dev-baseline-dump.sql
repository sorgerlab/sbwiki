-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: devpipeline
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `pipeline_archive`
--

DROP TABLE IF EXISTS `pipeline_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_archive` (
  `ar_namespace` int(11) NOT NULL DEFAULT '0',
  `ar_title` varbinary(255) NOT NULL DEFAULT '',
  `ar_text` mediumblob NOT NULL,
  `ar_comment` tinyblob NOT NULL,
  `ar_user` int(10) unsigned NOT NULL DEFAULT '0',
  `ar_user_text` varbinary(255) NOT NULL,
  `ar_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `ar_minor_edit` tinyint(4) NOT NULL DEFAULT '0',
  `ar_flags` tinyblob NOT NULL,
  `ar_rev_id` int(10) unsigned DEFAULT NULL,
  `ar_text_id` int(10) unsigned DEFAULT NULL,
  `ar_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `ar_len` int(10) unsigned DEFAULT NULL,
  `ar_page_id` int(10) unsigned DEFAULT NULL,
  `ar_parent_id` int(10) unsigned DEFAULT NULL,
  KEY `name_title_timestamp` (`ar_namespace`,`ar_title`,`ar_timestamp`),
  KEY `usertext_timestamp` (`ar_user_text`,`ar_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_archive`
--

LOCK TABLES `pipeline_archive` WRITE;
/*!40000 ALTER TABLE `pipeline_archive` DISABLE KEYS */;
INSERT INTO `pipeline_archive` VALUES (102,'Initials','','Created page with \"A user\'s initials.  Used to create SUID page titles.  Its type is [[has type::type:string|string]].\"',1,'WikiSysop','20110328212920',0,'',4,4,0,99,4,NULL),(6,'SemanticBiology_Add.png','','SemanticBiology \"add\" icon',1,'WikiSysop','20110328212722',0,'',2,2,0,26,2,NULL),(6,'SemanticBiology_Warning.png','','SemanticBiology \"warning\" icon',1,'WikiSysop','20110328212748',0,'',3,3,0,30,3,NULL);
/*!40000 ALTER TABLE `pipeline_archive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_category`
--

DROP TABLE IF EXISTS `pipeline_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_category` (
  `cat_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cat_title` varbinary(255) NOT NULL,
  `cat_pages` int(11) NOT NULL DEFAULT '0',
  `cat_subcats` int(11) NOT NULL DEFAULT '0',
  `cat_files` int(11) NOT NULL DEFAULT '0',
  `cat_hidden` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`cat_id`),
  UNIQUE KEY `cat_title` (`cat_title`),
  KEY `cat_pages` (`cat_pages`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_category`
--

LOCK TABLES `pipeline_category` WRITE;
/*!40000 ALTER TABLE `pipeline_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_categorylinks`
--

DROP TABLE IF EXISTS `pipeline_categorylinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_categorylinks` (
  `cl_from` int(10) unsigned NOT NULL DEFAULT '0',
  `cl_to` varbinary(255) NOT NULL DEFAULT '',
  `cl_sortkey` varbinary(70) NOT NULL DEFAULT '',
  `cl_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `cl_from` (`cl_from`,`cl_to`),
  KEY `cl_sortkey` (`cl_to`,`cl_sortkey`,`cl_from`),
  KEY `cl_timestamp` (`cl_to`,`cl_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_categorylinks`
--

LOCK TABLES `pipeline_categorylinks` WRITE;
/*!40000 ALTER TABLE `pipeline_categorylinks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_categorylinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_change_tag`
--

DROP TABLE IF EXISTS `pipeline_change_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_change_tag` (
  `ct_rc_id` int(11) DEFAULT NULL,
  `ct_log_id` int(11) DEFAULT NULL,
  `ct_rev_id` int(11) DEFAULT NULL,
  `ct_tag` varbinary(255) NOT NULL,
  `ct_params` blob,
  UNIQUE KEY `change_tag_rc_tag` (`ct_rc_id`,`ct_tag`),
  UNIQUE KEY `change_tag_log_tag` (`ct_log_id`,`ct_tag`),
  UNIQUE KEY `change_tag_rev_tag` (`ct_rev_id`,`ct_tag`),
  KEY `change_tag_tag_id` (`ct_tag`,`ct_rc_id`,`ct_rev_id`,`ct_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_change_tag`
--

LOCK TABLES `pipeline_change_tag` WRITE;
/*!40000 ALTER TABLE `pipeline_change_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_change_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_external_user`
--

DROP TABLE IF EXISTS `pipeline_external_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_external_user` (
  `eu_local_id` int(10) unsigned NOT NULL,
  `eu_external_id` varbinary(255) NOT NULL,
  PRIMARY KEY (`eu_local_id`),
  UNIQUE KEY `eu_external_id` (`eu_external_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_external_user`
--

LOCK TABLES `pipeline_external_user` WRITE;
/*!40000 ALTER TABLE `pipeline_external_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_external_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_externallinks`
--

DROP TABLE IF EXISTS `pipeline_externallinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_externallinks` (
  `el_from` int(10) unsigned NOT NULL DEFAULT '0',
  `el_to` blob NOT NULL,
  `el_index` blob NOT NULL,
  KEY `el_from` (`el_from`,`el_to`(40)),
  KEY `el_to` (`el_to`(60),`el_from`),
  KEY `el_index` (`el_index`(60))
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_externallinks`
--

LOCK TABLES `pipeline_externallinks` WRITE;
/*!40000 ALTER TABLE `pipeline_externallinks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_externallinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_filearchive`
--

DROP TABLE IF EXISTS `pipeline_filearchive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_filearchive` (
  `fa_id` int(11) NOT NULL AUTO_INCREMENT,
  `fa_name` varbinary(255) NOT NULL DEFAULT '',
  `fa_archive_name` varbinary(255) DEFAULT '',
  `fa_storage_group` varbinary(16) DEFAULT NULL,
  `fa_storage_key` varbinary(64) DEFAULT '',
  `fa_deleted_user` int(11) DEFAULT NULL,
  `fa_deleted_timestamp` binary(14) DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `fa_deleted_reason` blob,
  `fa_size` int(10) unsigned DEFAULT '0',
  `fa_width` int(11) DEFAULT '0',
  `fa_height` int(11) DEFAULT '0',
  `fa_metadata` mediumblob,
  `fa_bits` int(11) DEFAULT '0',
  `fa_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE') DEFAULT NULL,
  `fa_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart') DEFAULT 'unknown',
  `fa_minor_mime` varbinary(100) DEFAULT 'unknown',
  `fa_description` tinyblob,
  `fa_user` int(10) unsigned DEFAULT '0',
  `fa_user_text` varbinary(255) DEFAULT NULL,
  `fa_timestamp` binary(14) DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `fa_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`fa_id`),
  KEY `fa_name` (`fa_name`,`fa_timestamp`),
  KEY `fa_storage_group` (`fa_storage_group`,`fa_storage_key`),
  KEY `fa_deleted_timestamp` (`fa_deleted_timestamp`),
  KEY `fa_user_timestamp` (`fa_user_text`,`fa_timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_filearchive`
--

LOCK TABLES `pipeline_filearchive` WRITE;
/*!40000 ALTER TABLE `pipeline_filearchive` DISABLE KEYS */;
INSERT INTO `pipeline_filearchive` VALUES (1,'SemanticBiology_Add.png',NULL,'deleted','mfq5jw86umjx8d296jdj5uxh5u1zfwc.png',3,'20110331182843','',847,16,16,'0',8,'BITMAP','image','png','SemanticBiology \"add\" icon ',1,'WikiSysop','20110328212722',0),(2,'SemanticBiology_Warning.png',NULL,'deleted','02ft2ftde1y2h6v85tmxjx567y3223c.png',3,'20110331182851','',526,11,12,'0',8,'BITMAP','image','png','SemanticBiology \"warning\" icon ',1,'WikiSysop','20110328212748',0);
/*!40000 ALTER TABLE `pipeline_filearchive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_hitcounter`
--

DROP TABLE IF EXISTS `pipeline_hitcounter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_hitcounter` (
  `hc_id` int(10) unsigned NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=latin1 MAX_ROWS=25000;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_hitcounter`
--

LOCK TABLES `pipeline_hitcounter` WRITE;
/*!40000 ALTER TABLE `pipeline_hitcounter` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_hitcounter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_image`
--

DROP TABLE IF EXISTS `pipeline_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_image` (
  `img_name` varbinary(255) NOT NULL DEFAULT '',
  `img_size` int(10) unsigned NOT NULL DEFAULT '0',
  `img_width` int(11) NOT NULL DEFAULT '0',
  `img_height` int(11) NOT NULL DEFAULT '0',
  `img_metadata` mediumblob NOT NULL,
  `img_bits` int(11) NOT NULL DEFAULT '0',
  `img_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE') DEFAULT NULL,
  `img_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart') NOT NULL DEFAULT 'unknown',
  `img_minor_mime` varbinary(100) NOT NULL DEFAULT 'unknown',
  `img_description` tinyblob NOT NULL,
  `img_user` int(10) unsigned NOT NULL DEFAULT '0',
  `img_user_text` varbinary(255) NOT NULL,
  `img_timestamp` varbinary(14) NOT NULL DEFAULT '',
  `img_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`img_name`),
  KEY `img_usertext_timestamp` (`img_user_text`,`img_timestamp`),
  KEY `img_size` (`img_size`),
  KEY `img_timestamp` (`img_timestamp`),
  KEY `img_sha1` (`img_sha1`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_image`
--

LOCK TABLES `pipeline_image` WRITE;
/*!40000 ALTER TABLE `pipeline_image` DISABLE KEYS */;
INSERT INTO `pipeline_image` VALUES ('SemanticBiology_Add.png',847,16,16,'0',8,'BITMAP','image','png','SemanticBiology initialization',3,'Jmuhlich','20110331183016','mfq5jw86umjx8d296jdj5uxh5u1zfwc'),('SemanticBiology_Warning.png',526,11,12,'0',8,'BITMAP','image','png','SemanticBiology initialization',3,'Jmuhlich','20110331183016','02ft2ftde1y2h6v85tmxjx567y3223c'),('Test.png',846,16,16,'0',8,'BITMAP','image','png','SemanticBiology initialization',3,'Jmuhlich','20110331183016','kt3fi393o91ayqj9aujh8jmscwiyyap');
/*!40000 ALTER TABLE `pipeline_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_imagelinks`
--

DROP TABLE IF EXISTS `pipeline_imagelinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_imagelinks` (
  `il_from` int(10) unsigned NOT NULL DEFAULT '0',
  `il_to` varbinary(255) NOT NULL DEFAULT '',
  UNIQUE KEY `il_from` (`il_from`,`il_to`),
  UNIQUE KEY `il_to` (`il_to`,`il_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_imagelinks`
--

LOCK TABLES `pipeline_imagelinks` WRITE;
/*!40000 ALTER TABLE `pipeline_imagelinks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_imagelinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_interwiki`
--

DROP TABLE IF EXISTS `pipeline_interwiki`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_interwiki` (
  `iw_prefix` varbinary(32) NOT NULL,
  `iw_url` blob NOT NULL,
  `iw_local` tinyint(1) NOT NULL,
  `iw_trans` tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `iw_prefix` (`iw_prefix`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_interwiki`
--

LOCK TABLES `pipeline_interwiki` WRITE;
/*!40000 ALTER TABLE `pipeline_interwiki` DISABLE KEYS */;
INSERT INTO `pipeline_interwiki` VALUES ('acronym','http://www.acronymfinder.com/af-query.asp?String=exact&Acronym=$1',0,0),('advogato','http://www.advogato.org/$1',0,0),('annotationwiki','http://www.seedwiki.com/page.cfm?wikiid=368&doc=$1',0,0),('arxiv','http://www.arxiv.org/abs/$1',0,0),('c2find','http://c2.com/cgi/wiki?FindPage&value=$1',0,0),('cache','http://www.google.com/search?q=cache:$1',0,0),('commons','http://commons.wikimedia.org/wiki/$1',0,0),('corpknowpedia','http://corpknowpedia.org/wiki/index.php/$1',0,0),('dictionary','http://www.dict.org/bin/Dict?Database=*&Form=Dict1&Strategy=*&Query=$1',0,0),('disinfopedia','http://www.disinfopedia.org/wiki.phtml?title=$1',0,0),('docbook','http://wiki.docbook.org/topic/$1',0,0),('doi','http://dx.doi.org/$1',0,0),('drumcorpswiki','http://www.drumcorpswiki.com/index.php/$1',0,0),('dwjwiki','http://www.suberic.net/cgi-bin/dwj/wiki.cgi?$1',0,0),('elibre','http://enciclopedia.us.es/index.php/$1',0,0),('emacswiki','http://www.emacswiki.org/cgi-bin/wiki.pl?$1',0,0),('foldoc','http://foldoc.org/?$1',0,0),('foxwiki','http://fox.wikis.com/wc.dll?Wiki~$1',0,0),('freebsdman','http://www.FreeBSD.org/cgi/man.cgi?apropos=1&query=$1',0,0),('gej','http://www.esperanto.de/cgi-bin/aktivikio/wiki.pl?$1',0,0),('gentoo-wiki','http://gentoo-wiki.com/$1',0,0),('google','http://www.google.com/search?q=$1',0,0),('googlegroups','http://groups.google.com/groups?q=$1',0,0),('hammondwiki','http://www.dairiki.org/HammondWiki/$1',0,0),('hewikisource','http://he.wikisource.org/wiki/$1',1,0),('hrwiki','http://www.hrwiki.org/index.php/$1',0,0),('imdb','http://us.imdb.com/Title?$1',0,0),('jargonfile','http://sunir.org/apps/meta.pl?wiki=JargonFile&redirect=$1',0,0),('jspwiki','http://www.jspwiki.org/wiki/$1',0,0),('keiki','http://kei.ki/en/$1',0,0),('kmwiki','http://kmwiki.wikispaces.com/$1',0,0),('linuxwiki','http://linuxwiki.de/$1',0,0),('lojban','http://www.lojban.org/tiki/tiki-index.php?page=$1',0,0),('lqwiki','http://wiki.linuxquestions.org/wiki/$1',0,0),('lugkr','http://lug-kr.sourceforge.net/cgi-bin/lugwiki.pl?$1',0,0),('mathsongswiki','http://SeedWiki.com/page.cfm?wikiid=237&doc=$1',0,0),('meatball','http://www.usemod.com/cgi-bin/mb.pl?$1',0,0),('mediawikiwiki','http://www.mediawiki.org/wiki/$1',0,0),('mediazilla','https://bugzilla.wikimedia.org/$1',1,0),('memoryalpha','http://www.memory-alpha.org/en/index.php/$1',0,0),('metawiki','http://sunir.org/apps/meta.pl?$1',0,0),('metawikipedia','http://meta.wikimedia.org/wiki/$1',0,0),('moinmoin','http://purl.net/wiki/moin/$1',0,0),('mozillawiki','http://wiki.mozilla.org/index.php/$1',0,0),('mw','http://www.mediawiki.org/wiki/$1',0,0),('oeis','http://www.research.att.com/cgi-bin/access.cgi/as/njas/sequences/eisA.cgi?Anum=$1',0,0),('openfacts','http://openfacts.berlios.de/index.phtml?title=$1',0,0),('openwiki','http://openwiki.com/?$1',0,0),('patwiki','http://gauss.ffii.org/$1',0,0),('pmeg','http://www.bertilow.com/pmeg/$1.php',0,0),('ppr','http://c2.com/cgi/wiki?$1',0,0),('pythoninfo','http://wiki.python.org/moin/$1',0,0),('rfc','http://www.rfc-editor.org/rfc/rfc$1.txt',0,0),('s23wiki','http://is-root.de/wiki/index.php/$1',0,0),('seattlewiki','http://seattle.wikia.com/wiki/$1',0,0),('seattlewireless','http://seattlewireless.net/?$1',0,0),('senseislibrary','http://senseis.xmp.net/?$1',0,0),('slashdot','http://slashdot.org/article.pl?sid=$1',0,0),('sourceforge','http://sourceforge.net/$1',0,0),('squeak','http://wiki.squeak.org/squeak/$1',0,0),('susning','http://www.susning.nu/$1',0,0),('svgwiki','http://wiki.svg.org/$1',0,0),('tavi','http://tavi.sourceforge.net/$1',0,0),('tejo','http://www.tejo.org/vikio/$1',0,0),('theopedia','http://www.theopedia.com/$1',0,0),('tmbw','http://www.tmbw.net/wiki/$1',0,0),('tmnet','http://www.technomanifestos.net/?$1',0,0),('tmwiki','http://www.EasyTopicMaps.com/?page=$1',0,0),('twiki','http://twiki.org/cgi-bin/view/$1',0,0),('uea','http://www.tejo.org/uea/$1',0,0),('unreal','http://wiki.beyondunreal.com/wiki/$1',0,0),('usemod','http://www.usemod.com/cgi-bin/wiki.pl?$1',0,0),('vinismo','http://vinismo.com/en/$1',0,0),('webseitzwiki','http://webseitz.fluxent.com/wiki/$1',0,0),('why','http://clublet.com/c/c/why?$1',0,0),('wiki','http://c2.com/cgi/wiki?$1',0,0),('wikia','http://www.wikia.com/wiki/$1',0,0),('wikibooks','http://en.wikibooks.org/wiki/$1',1,0),('wikicities','http://www.wikia.com/wiki/$1',0,0),('wikif1','http://www.wikif1.org/$1',0,0),('wikihow','http://www.wikihow.com/$1',0,0),('wikimedia','http://wikimediafoundation.org/wiki/$1',0,0),('wikinews','http://en.wikinews.org/wiki/$1',1,0),('wikinfo','http://www.wikinfo.org/index.php/$1',0,0),('wikipedia','http://en.wikipedia.org/wiki/$1',1,0),('wikiquote','http://en.wikiquote.org/wiki/$1',1,0),('wikisource','http://wikisource.org/wiki/$1',1,0),('wikispecies','http://species.wikimedia.org/wiki/$1',1,0),('wikitravel','http://wikitravel.org/en/$1',0,0),('wikiversity','http://en.wikiversity.org/wiki/$1',1,0),('wikt','http://en.wiktionary.org/wiki/$1',1,0),('wiktionary','http://en.wiktionary.org/wiki/$1',1,0),('wlug','http://www.wlug.org.nz/$1',0,0),('zwiki','http://zwiki.org/$1',0,0),('zzz wiki','http://wiki.zzz.ee/index.php/$1',0,0);
/*!40000 ALTER TABLE `pipeline_interwiki` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_ipblocks`
--

DROP TABLE IF EXISTS `pipeline_ipblocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_ipblocks` (
  `ipb_id` int(11) NOT NULL AUTO_INCREMENT,
  `ipb_address` tinyblob NOT NULL,
  `ipb_user` int(10) unsigned NOT NULL DEFAULT '0',
  `ipb_by` int(10) unsigned NOT NULL DEFAULT '0',
  `ipb_by_text` varbinary(255) NOT NULL DEFAULT '',
  `ipb_reason` tinyblob NOT NULL,
  `ipb_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `ipb_auto` tinyint(1) NOT NULL DEFAULT '0',
  `ipb_anon_only` tinyint(1) NOT NULL DEFAULT '0',
  `ipb_create_account` tinyint(1) NOT NULL DEFAULT '1',
  `ipb_enable_autoblock` tinyint(1) NOT NULL DEFAULT '1',
  `ipb_expiry` varbinary(14) NOT NULL DEFAULT '',
  `ipb_range_start` tinyblob NOT NULL,
  `ipb_range_end` tinyblob NOT NULL,
  `ipb_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `ipb_block_email` tinyint(1) NOT NULL DEFAULT '0',
  `ipb_allow_usertalk` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ipb_id`),
  UNIQUE KEY `ipb_address` (`ipb_address`(255),`ipb_user`,`ipb_auto`,`ipb_anon_only`),
  KEY `ipb_user` (`ipb_user`),
  KEY `ipb_range` (`ipb_range_start`(8),`ipb_range_end`(8)),
  KEY `ipb_timestamp` (`ipb_timestamp`),
  KEY `ipb_expiry` (`ipb_expiry`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_ipblocks`
--

LOCK TABLES `pipeline_ipblocks` WRITE;
/*!40000 ALTER TABLE `pipeline_ipblocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_ipblocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_job`
--

DROP TABLE IF EXISTS `pipeline_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_job` (
  `job_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job_cmd` varbinary(60) NOT NULL DEFAULT '',
  `job_namespace` int(11) NOT NULL,
  `job_title` varbinary(255) NOT NULL,
  `job_params` blob NOT NULL,
  PRIMARY KEY (`job_id`),
  KEY `job_cmd` (`job_cmd`,`job_namespace`,`job_title`,`job_params`(128))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_job`
--

LOCK TABLES `pipeline_job` WRITE;
/*!40000 ALTER TABLE `pipeline_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_l10n_cache`
--

DROP TABLE IF EXISTS `pipeline_l10n_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_l10n_cache` (
  `lc_lang` varbinary(32) NOT NULL,
  `lc_key` varbinary(255) NOT NULL,
  `lc_value` mediumblob NOT NULL,
  KEY `lc_lang_key` (`lc_lang`,`lc_key`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_l10n_cache`
--

LOCK TABLES `pipeline_l10n_cache` WRITE;
/*!40000 ALTER TABLE `pipeline_l10n_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_l10n_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_langlinks`
--

DROP TABLE IF EXISTS `pipeline_langlinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_langlinks` (
  `ll_from` int(10) unsigned NOT NULL DEFAULT '0',
  `ll_lang` varbinary(20) NOT NULL DEFAULT '',
  `ll_title` varbinary(255) NOT NULL DEFAULT '',
  UNIQUE KEY `ll_from` (`ll_from`,`ll_lang`),
  KEY `ll_lang` (`ll_lang`,`ll_title`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_langlinks`
--

LOCK TABLES `pipeline_langlinks` WRITE;
/*!40000 ALTER TABLE `pipeline_langlinks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_langlinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_log_search`
--

DROP TABLE IF EXISTS `pipeline_log_search`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_log_search` (
  `ls_field` varbinary(32) NOT NULL,
  `ls_value` varbinary(255) NOT NULL,
  `ls_log_id` int(10) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `ls_field_val` (`ls_field`,`ls_value`,`ls_log_id`),
  KEY `ls_log_id` (`ls_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_log_search`
--

LOCK TABLES `pipeline_log_search` WRITE;
/*!40000 ALTER TABLE `pipeline_log_search` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_log_search` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_logging`
--

DROP TABLE IF EXISTS `pipeline_logging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_logging` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `log_type` varbinary(32) NOT NULL DEFAULT '',
  `log_action` varbinary(32) NOT NULL DEFAULT '',
  `log_timestamp` binary(14) NOT NULL DEFAULT '19700101000000',
  `log_user` int(10) unsigned NOT NULL DEFAULT '0',
  `log_user_text` varbinary(255) NOT NULL DEFAULT '',
  `log_namespace` int(11) NOT NULL DEFAULT '0',
  `log_title` varbinary(255) NOT NULL DEFAULT '',
  `log_page` int(10) unsigned DEFAULT NULL,
  `log_comment` varbinary(255) NOT NULL DEFAULT '',
  `log_params` blob NOT NULL,
  `log_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`log_id`),
  KEY `type_time` (`log_type`,`log_timestamp`),
  KEY `user_time` (`log_user`,`log_timestamp`),
  KEY `page_time` (`log_namespace`,`log_title`,`log_timestamp`),
  KEY `times` (`log_timestamp`),
  KEY `log_user_type_time` (`log_user`,`log_type`,`log_timestamp`),
  KEY `log_page_id_time` (`log_page`,`log_timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_logging`
--

LOCK TABLES `pipeline_logging` WRITE;
/*!40000 ALTER TABLE `pipeline_logging` DISABLE KEYS */;
INSERT INTO `pipeline_logging` VALUES (1,'newusers','create2','20110328212559',1,'WikiSysop',2,'Ontologybot',0,'','2',0),(2,'newusers','create2','20110328212615',1,'WikiSysop',2,'Jmuhlich',0,'','3',0),(3,'rights','rights','20110328212628',1,'WikiSysop',2,'Jmuhlich',0,'','\nsysop, bureaucrat',0),(4,'rights','rights','20110328212642',1,'WikiSysop',2,'Ontologybot',0,'','\nbot, sysop',0),(5,'upload','upload','20110328212722',1,'WikiSysop',6,'SemanticBiology_Add.png',0,'SemanticBiology \"add\" icon ','',0),(6,'upload','upload','20110328212748',1,'WikiSysop',6,'SemanticBiology_Warning.png',0,'SemanticBiology \"warning\" icon ','',0),(7,'patrol','patrol','20110328212920',1,'WikiSysop',102,'Initials',4,'','4\n0\n1',0),(8,'patrol','patrol','20110328213005',3,'Jmuhlich',2,'Jmuhlich',5,'','5\n0\n1',0),(9,'delete','delete','20110331182822',3,'Jmuhlich',102,'Initials',0,'','',0),(10,'delete','delete','20110331182843',3,'Jmuhlich',6,'SemanticBiology_Add.png',0,'','',0),(11,'delete','delete','20110331182851',3,'Jmuhlich',6,'SemanticBiology_Warning.png',0,'','',0),(12,'patrol','patrol','20110331183016',3,'Jmuhlich',102,'Initials',6,'','6\n0\n1',0),(13,'patrol','patrol','20110331183016',3,'Jmuhlich',10,'Categoryhelper_table_end',7,'','7\n0\n1',0),(14,'patrol','patrol','20110331183016',3,'Jmuhlich',10,'Import_generated_content',8,'','8\n0\n1',0),(15,'upload','upload','20110331183016',3,'Jmuhlich',6,'SemanticBiology_Add.png',0,'SemanticBiology initialization','',0),(16,'upload','upload','20110331183016',3,'Jmuhlich',6,'SemanticBiology_Warning.png',0,'SemanticBiology initialization','',0),(17,'upload','upload','20110331183016',3,'Jmuhlich',6,'Test.png',0,'SemanticBiology initialization','',0);
/*!40000 ALTER TABLE `pipeline_logging` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_math`
--

DROP TABLE IF EXISTS `pipeline_math`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_math` (
  `math_inputhash` varbinary(16) NOT NULL,
  `math_outputhash` varbinary(16) NOT NULL,
  `math_html_conservativeness` tinyint(4) NOT NULL,
  `math_html` blob,
  `math_mathml` blob,
  UNIQUE KEY `math_inputhash` (`math_inputhash`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_math`
--

LOCK TABLES `pipeline_math` WRITE;
/*!40000 ALTER TABLE `pipeline_math` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_math` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_objectcache`
--

DROP TABLE IF EXISTS `pipeline_objectcache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_objectcache` (
  `keyname` varbinary(255) NOT NULL DEFAULT '',
  `value` mediumblob,
  `exptime` datetime DEFAULT NULL,
  PRIMARY KEY (`keyname`),
  KEY `exptime` (`exptime`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_objectcache`
--

LOCK TABLES `pipeline_objectcache` WRITE;
/*!40000 ALTER TABLE `pipeline_objectcache` DISABLE KEYS */;
INSERT INTO `pipeline_objectcache` VALUES ('devpipeline-pipeline_:messages:en','K´2´ª.¶2·R\ns\r\nöô÷S²Î´2´®\0','2011-04-12 20:22:54');
/*!40000 ALTER TABLE `pipeline_objectcache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_oldimage`
--

DROP TABLE IF EXISTS `pipeline_oldimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_oldimage` (
  `oi_name` varbinary(255) NOT NULL DEFAULT '',
  `oi_archive_name` varbinary(255) NOT NULL DEFAULT '',
  `oi_size` int(10) unsigned NOT NULL DEFAULT '0',
  `oi_width` int(11) NOT NULL DEFAULT '0',
  `oi_height` int(11) NOT NULL DEFAULT '0',
  `oi_bits` int(11) NOT NULL DEFAULT '0',
  `oi_description` tinyblob NOT NULL,
  `oi_user` int(10) unsigned NOT NULL DEFAULT '0',
  `oi_user_text` varbinary(255) NOT NULL,
  `oi_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `oi_metadata` mediumblob NOT NULL,
  `oi_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE') DEFAULT NULL,
  `oi_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart') NOT NULL DEFAULT 'unknown',
  `oi_minor_mime` varbinary(100) NOT NULL DEFAULT 'unknown',
  `oi_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `oi_sha1` varbinary(32) NOT NULL DEFAULT '',
  KEY `oi_usertext_timestamp` (`oi_user_text`,`oi_timestamp`),
  KEY `oi_name_timestamp` (`oi_name`,`oi_timestamp`),
  KEY `oi_name_archive_name` (`oi_name`,`oi_archive_name`(14)),
  KEY `oi_sha1` (`oi_sha1`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_oldimage`
--

LOCK TABLES `pipeline_oldimage` WRITE;
/*!40000 ALTER TABLE `pipeline_oldimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_oldimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_page`
--

DROP TABLE IF EXISTS `pipeline_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_page` (
  `page_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_namespace` int(11) NOT NULL,
  `page_title` varbinary(255) NOT NULL,
  `page_restrictions` tinyblob NOT NULL,
  `page_counter` bigint(20) unsigned NOT NULL DEFAULT '0',
  `page_is_redirect` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `page_is_new` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `page_random` double unsigned NOT NULL,
  `page_touched` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `page_latest` int(10) unsigned NOT NULL,
  `page_len` int(10) unsigned NOT NULL,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY `name_title` (`page_namespace`,`page_title`),
  KEY `page_random` (`page_random`),
  KEY `page_len` (`page_len`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_page`
--

LOCK TABLES `pipeline_page` WRITE;
/*!40000 ALTER TABLE `pipeline_page` DISABLE KEYS */;
INSERT INTO `pipeline_page` VALUES (1,0,'Main_Page','',7,0,0,0.027945686753,'20110411211310',1,438),(5,2,'Jmuhlich','',2,0,1,0.925887449058,'20110411211311',5,27),(6,102,'Initials','',0,0,1,0.801097187366,'20110411211313',6,99),(7,10,'Categoryhelper_table_end','',0,0,1,0.579324587693,'20110411211312',7,108),(8,10,'Import_generated_content','',0,0,1,0.748579295208,'20110411211313',8,170),(9,6,'SemanticBiology_Add.png','',1,0,1,0.904905519205,'20110411211311',9,10),(10,6,'SemanticBiology_Warning.png','',0,0,1,0.322663420363,'20110411211311',10,12),(11,6,'Test.png','',0,0,1,0.435916489527,'20110411211312',11,7);
/*!40000 ALTER TABLE `pipeline_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_page_props`
--

DROP TABLE IF EXISTS `pipeline_page_props`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_page_props` (
  `pp_page` int(11) NOT NULL,
  `pp_propname` varbinary(60) NOT NULL,
  `pp_value` blob NOT NULL,
  UNIQUE KEY `pp_page_propname` (`pp_page`,`pp_propname`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_page_props`
--

LOCK TABLES `pipeline_page_props` WRITE;
/*!40000 ALTER TABLE `pipeline_page_props` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_page_props` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_page_restrictions`
--

DROP TABLE IF EXISTS `pipeline_page_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_page_restrictions` (
  `pr_page` int(11) NOT NULL,
  `pr_type` varbinary(60) NOT NULL,
  `pr_level` varbinary(60) NOT NULL,
  `pr_cascade` tinyint(4) NOT NULL,
  `pr_user` int(11) DEFAULT NULL,
  `pr_expiry` varbinary(14) DEFAULT NULL,
  `pr_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`pr_id`),
  UNIQUE KEY `pr_pagetype` (`pr_page`,`pr_type`),
  KEY `pr_typelevel` (`pr_type`,`pr_level`),
  KEY `pr_level` (`pr_level`),
  KEY `pr_cascade` (`pr_cascade`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_page_restrictions`
--

LOCK TABLES `pipeline_page_restrictions` WRITE;
/*!40000 ALTER TABLE `pipeline_page_restrictions` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_page_restrictions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_pagelinks`
--

DROP TABLE IF EXISTS `pipeline_pagelinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_pagelinks` (
  `pl_from` int(10) unsigned NOT NULL DEFAULT '0',
  `pl_namespace` int(11) NOT NULL DEFAULT '0',
  `pl_title` varbinary(255) NOT NULL DEFAULT '',
  UNIQUE KEY `pl_from` (`pl_from`,`pl_namespace`,`pl_title`),
  UNIQUE KEY `pl_namespace` (`pl_namespace`,`pl_title`,`pl_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_pagelinks`
--

LOCK TABLES `pipeline_pagelinks` WRITE;
/*!40000 ALTER TABLE `pipeline_pagelinks` DISABLE KEYS */;
INSERT INTO `pipeline_pagelinks` VALUES (6,104,'String');
/*!40000 ALTER TABLE `pipeline_pagelinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_profiling`
--

DROP TABLE IF EXISTS `pipeline_profiling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_profiling` (
  `pf_count` int(11) NOT NULL DEFAULT '0',
  `pf_time` float NOT NULL DEFAULT '0',
  `pf_memory` float NOT NULL DEFAULT '0',
  `pf_name` varchar(255) NOT NULL DEFAULT '',
  `pf_server` varchar(30) NOT NULL DEFAULT '',
  UNIQUE KEY `pf_name_server` (`pf_name`,`pf_server`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_profiling`
--

LOCK TABLES `pipeline_profiling` WRITE;
/*!40000 ALTER TABLE `pipeline_profiling` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_profiling` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_protected_titles`
--

DROP TABLE IF EXISTS `pipeline_protected_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_protected_titles` (
  `pt_namespace` int(11) NOT NULL,
  `pt_title` varbinary(255) NOT NULL,
  `pt_user` int(10) unsigned NOT NULL,
  `pt_reason` tinyblob,
  `pt_timestamp` binary(14) NOT NULL,
  `pt_expiry` varbinary(14) NOT NULL DEFAULT '',
  `pt_create_perm` varbinary(60) NOT NULL,
  UNIQUE KEY `pt_namespace_title` (`pt_namespace`,`pt_title`),
  KEY `pt_timestamp` (`pt_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_protected_titles`
--

LOCK TABLES `pipeline_protected_titles` WRITE;
/*!40000 ALTER TABLE `pipeline_protected_titles` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_protected_titles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_querycache`
--

DROP TABLE IF EXISTS `pipeline_querycache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_querycache` (
  `qc_type` varbinary(32) NOT NULL,
  `qc_value` int(10) unsigned NOT NULL DEFAULT '0',
  `qc_namespace` int(11) NOT NULL DEFAULT '0',
  `qc_title` varbinary(255) NOT NULL DEFAULT '',
  KEY `qc_type` (`qc_type`,`qc_value`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_querycache`
--

LOCK TABLES `pipeline_querycache` WRITE;
/*!40000 ALTER TABLE `pipeline_querycache` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_querycache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_querycache_info`
--

DROP TABLE IF EXISTS `pipeline_querycache_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_querycache_info` (
  `qci_type` varbinary(32) NOT NULL DEFAULT '',
  `qci_timestamp` binary(14) NOT NULL DEFAULT '19700101000000',
  UNIQUE KEY `qci_type` (`qci_type`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_querycache_info`
--

LOCK TABLES `pipeline_querycache_info` WRITE;
/*!40000 ALTER TABLE `pipeline_querycache_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_querycache_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_querycachetwo`
--

DROP TABLE IF EXISTS `pipeline_querycachetwo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_querycachetwo` (
  `qcc_type` varbinary(32) NOT NULL,
  `qcc_value` int(10) unsigned NOT NULL DEFAULT '0',
  `qcc_namespace` int(11) NOT NULL DEFAULT '0',
  `qcc_title` varbinary(255) NOT NULL DEFAULT '',
  `qcc_namespacetwo` int(11) NOT NULL DEFAULT '0',
  `qcc_titletwo` varbinary(255) NOT NULL DEFAULT '',
  KEY `qcc_type` (`qcc_type`,`qcc_value`),
  KEY `qcc_title` (`qcc_type`,`qcc_namespace`,`qcc_title`),
  KEY `qcc_titletwo` (`qcc_type`,`qcc_namespacetwo`,`qcc_titletwo`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_querycachetwo`
--

LOCK TABLES `pipeline_querycachetwo` WRITE;
/*!40000 ALTER TABLE `pipeline_querycachetwo` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_querycachetwo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_recentchanges`
--

DROP TABLE IF EXISTS `pipeline_recentchanges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_recentchanges` (
  `rc_id` int(11) NOT NULL AUTO_INCREMENT,
  `rc_timestamp` varbinary(14) NOT NULL DEFAULT '',
  `rc_cur_time` varbinary(14) NOT NULL DEFAULT '',
  `rc_user` int(10) unsigned NOT NULL DEFAULT '0',
  `rc_user_text` varbinary(255) NOT NULL,
  `rc_namespace` int(11) NOT NULL DEFAULT '0',
  `rc_title` varbinary(255) NOT NULL DEFAULT '',
  `rc_comment` varbinary(255) NOT NULL DEFAULT '',
  `rc_minor` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_bot` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_new` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_cur_id` int(10) unsigned NOT NULL DEFAULT '0',
  `rc_this_oldid` int(10) unsigned NOT NULL DEFAULT '0',
  `rc_last_oldid` int(10) unsigned NOT NULL DEFAULT '0',
  `rc_type` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_moved_to_ns` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_moved_to_title` varbinary(255) NOT NULL DEFAULT '',
  `rc_patrolled` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_ip` varbinary(40) NOT NULL DEFAULT '',
  `rc_old_len` int(11) DEFAULT NULL,
  `rc_new_len` int(11) DEFAULT NULL,
  `rc_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rc_logid` int(10) unsigned NOT NULL DEFAULT '0',
  `rc_log_type` varbinary(255) DEFAULT NULL,
  `rc_log_action` varbinary(255) DEFAULT NULL,
  `rc_params` blob,
  PRIMARY KEY (`rc_id`),
  KEY `rc_timestamp` (`rc_timestamp`),
  KEY `rc_namespace_title` (`rc_namespace`,`rc_title`),
  KEY `rc_cur_id` (`rc_cur_id`),
  KEY `new_name_timestamp` (`rc_new`,`rc_namespace`,`rc_timestamp`),
  KEY `rc_ip` (`rc_ip`),
  KEY `rc_ns_usertext` (`rc_namespace`,`rc_user_text`),
  KEY `rc_user_text` (`rc_user_text`,`rc_timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_recentchanges`
--

LOCK TABLES `pipeline_recentchanges` WRITE;
/*!40000 ALTER TABLE `pipeline_recentchanges` DISABLE KEYS */;
INSERT INTO `pipeline_recentchanges` VALUES (1,'20110328212559','20110328212559',1,'WikiSysop',2,'Ontologybot','',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,1,'newusers','create2','2'),(2,'20110328212615','20110328212615',1,'WikiSysop',2,'Jmuhlich','',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,2,'newusers','create2','3'),(3,'20110328212628','20110328212628',1,'WikiSysop',2,'Jmuhlich','',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,3,'rights','rights','\nsysop, bureaucrat'),(4,'20110328212642','20110328212642',1,'WikiSysop',2,'Ontologybot','',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,4,'rights','rights','\nbot, sysop'),(5,'20110328212722','20110328212722',1,'WikiSysop',6,'SemanticBiology_Add.png','SemanticBiology \"add\" icon ',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,5,'upload','upload',''),(6,'20110328212748','20110328212748',1,'WikiSysop',6,'SemanticBiology_Warning.png','SemanticBiology \"warning\" icon ',0,0,0,0,0,0,3,0,'',1,'10.0.105.180',NULL,NULL,0,6,'upload','upload',''),(8,'20110328213005','20110328213005',3,'Jmuhlich',2,'Jmuhlich','Created page with \"Initials: [[initials::JLM]]\"',0,0,1,5,5,0,1,0,'',1,'10.0.105.180',0,27,0,0,NULL,'',''),(9,'20110331182822','20110331182822',3,'Jmuhlich',102,'Initials','',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,9,'delete','delete',''),(10,'20110331182843','20110331182843',3,'Jmuhlich',6,'SemanticBiology_Add.png','',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,10,'delete','delete',''),(11,'20110331182851','20110331182851',3,'Jmuhlich',6,'SemanticBiology_Warning.png','',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,11,'delete','delete',''),(12,'20110331183016','20110331183016',3,'Jmuhlich',102,'Initials','SemanticBiology initialization',0,0,1,6,6,0,1,0,'',1,'66.30.72.107',0,99,0,0,NULL,'',''),(13,'20110331183016','20110331183016',3,'Jmuhlich',10,'Categoryhelper_table_end','SemanticBiology initialization',0,0,1,7,7,0,1,0,'',1,'66.30.72.107',0,108,0,0,NULL,'',''),(14,'20110331183016','20110331183016',3,'Jmuhlich',10,'Import_generated_content','SemanticBiology initialization',0,0,1,8,8,0,1,0,'',1,'66.30.72.107',0,170,0,0,NULL,'',''),(15,'20110331183016','20110331183016',3,'Jmuhlich',6,'SemanticBiology_Add.png','SemanticBiology initialization',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,15,'upload','upload',''),(16,'20110331183016','20110331183016',3,'Jmuhlich',6,'SemanticBiology_Warning.png','SemanticBiology initialization',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,16,'upload','upload',''),(17,'20110331183016','20110331183016',3,'Jmuhlich',6,'Test.png','SemanticBiology initialization',0,0,0,0,0,0,3,0,'',1,'66.30.72.107',NULL,NULL,0,17,'upload','upload','');
/*!40000 ALTER TABLE `pipeline_recentchanges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_redirect`
--

DROP TABLE IF EXISTS `pipeline_redirect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_redirect` (
  `rd_from` int(10) unsigned NOT NULL DEFAULT '0',
  `rd_namespace` int(11) NOT NULL DEFAULT '0',
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) DEFAULT NULL,
  `rd_fragment` varbinary(255) DEFAULT NULL,
  PRIMARY KEY (`rd_from`),
  KEY `rd_ns_title` (`rd_namespace`,`rd_title`,`rd_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_redirect`
--

LOCK TABLES `pipeline_redirect` WRITE;
/*!40000 ALTER TABLE `pipeline_redirect` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_redirect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_revision`
--

DROP TABLE IF EXISTS `pipeline_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_revision` (
  `rev_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rev_page` int(10) unsigned NOT NULL,
  `rev_text_id` int(10) unsigned NOT NULL,
  `rev_comment` tinyblob NOT NULL,
  `rev_user` int(10) unsigned NOT NULL DEFAULT '0',
  `rev_user_text` varbinary(255) NOT NULL DEFAULT '',
  `rev_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `rev_minor_edit` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rev_deleted` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rev_len` int(10) unsigned DEFAULT NULL,
  `rev_parent_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`rev_id`),
  UNIQUE KEY `rev_page_id` (`rev_page`,`rev_id`),
  KEY `rev_timestamp` (`rev_timestamp`),
  KEY `page_timestamp` (`rev_page`,`rev_timestamp`),
  KEY `user_timestamp` (`rev_user`,`rev_timestamp`),
  KEY `usertext_timestamp` (`rev_user_text`,`rev_timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=binary MAX_ROWS=10000000 AVG_ROW_LENGTH=1024;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_revision`
--

LOCK TABLES `pipeline_revision` WRITE;
/*!40000 ALTER TABLE `pipeline_revision` DISABLE KEYS */;
INSERT INTO `pipeline_revision` VALUES (1,1,1,'',0,'MediaWiki default','20110328212231',0,0,438,0),(5,5,5,'Created page with \"Initials: [[initials::JLM]]\"',3,'Jmuhlich','20110328213005',0,0,27,0),(6,6,6,'SemanticBiology initialization',3,'Jmuhlich','20110331183016',0,0,99,0),(7,7,7,'SemanticBiology initialization',3,'Jmuhlich','20110331183016',0,0,108,0),(8,8,8,'SemanticBiology initialization',3,'Jmuhlich','20110331183016',0,0,170,0),(9,9,9,'SemanticBiology initialization',3,'Jmuhlich','20110331183016',0,0,10,0),(10,10,10,'SemanticBiology initialization',3,'Jmuhlich','20110331183016',0,0,12,0),(11,11,11,'SemanticBiology initialization',3,'Jmuhlich','20110331183017',0,0,7,0);
/*!40000 ALTER TABLE `pipeline_revision` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_sbw_uid`
--

DROP TABLE IF EXISTS `pipeline_sbw_uid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_sbw_uid` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type_code` binary(2) NOT NULL,
  `creator_initials` binary(3) NOT NULL,
  `annotation` varbinary(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_sbw_uid`
--

LOCK TABLES `pipeline_sbw_uid` WRITE;
/*!40000 ALTER TABLE `pipeline_sbw_uid` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_sbw_uid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_searchindex`
--

DROP TABLE IF EXISTS `pipeline_searchindex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_searchindex` (
  `si_page` int(10) unsigned NOT NULL,
  `si_title` varchar(255) NOT NULL DEFAULT '',
  `si_text` mediumtext NOT NULL,
  UNIQUE KEY `si_page` (`si_page`),
  FULLTEXT KEY `si_title` (`si_title`),
  FULLTEXT KEY `si_text` (`si_text`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_searchindex`
--

LOCK TABLES `pipeline_searchindex` WRITE;
/*!40000 ALTER TABLE `pipeline_searchindex` DISABLE KEYS */;
INSERT INTO `pipeline_searchindex` VALUES (2,'semanticbiology addu800u82epngu800',' semanticbiology addu800 icon '),(3,'semanticbiology warningu82epngu800',' semanticbiology warning icon '),(4,'initials',' au800 user user\'su800 initials. used tou800 create suid page titles. itsu800 type isu800 hasu800 type type string string . '),(5,'jmuhlich',' initials initials jlmu800 '),(6,'initials',' au800 user user\'su800 initials. used tou800 create suid page titles. itsu800 type isu800 hasu800 type type string string . '),(7,'categoryhelper table endu800',' used asu800 au800 final hidden template tou800 close outu800 infoboxes. '),(8,'import generated content',' used tou800 provide au800 hidden form field where sbwiki importer tools canu800 place automatically generated content. content '),(9,'semanticbiology addu800u82epngu800',' addu800 button '),(10,'semanticbiology warningu82epngu800',' warning icon '),(11,'testu82epngu800',' testing ');
/*!40000 ALTER TABLE `pipeline_searchindex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_site_stats`
--

DROP TABLE IF EXISTS `pipeline_site_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_site_stats` (
  `ss_row_id` int(10) unsigned NOT NULL,
  `ss_total_views` bigint(20) unsigned DEFAULT '0',
  `ss_total_edits` bigint(20) unsigned DEFAULT '0',
  `ss_good_articles` bigint(20) unsigned DEFAULT '0',
  `ss_total_pages` bigint(20) DEFAULT '-1',
  `ss_users` bigint(20) DEFAULT '-1',
  `ss_active_users` bigint(20) DEFAULT '-1',
  `ss_admins` int(11) DEFAULT '-1',
  `ss_images` int(11) DEFAULT '0',
  UNIQUE KEY `ss_row_id` (`ss_row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_site_stats`
--

LOCK TABLES `pipeline_site_stats` WRITE;
/*!40000 ALTER TABLE `pipeline_site_stats` DISABLE KEYS */;
INSERT INTO `pipeline_site_stats` VALUES (1,17,14,0,8,3,-1,1,3);
/*!40000 ALTER TABLE `pipeline_site_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_atts2`
--

DROP TABLE IF EXISTS `pipeline_smw_atts2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_atts2` (
  `s_id` int(8) unsigned NOT NULL,
  `p_id` int(8) unsigned NOT NULL,
  `value_xsd` varbinary(255) DEFAULT NULL,
  `value_num` double DEFAULT NULL,
  `value_unit` varbinary(63) DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `p_id` (`p_id`),
  KEY `value_num` (`value_num`),
  KEY `value_xsd` (`value_xsd`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_atts2`
--

LOCK TABLES `pipeline_smw_atts2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_atts2` DISABLE KEYS */;
INSERT INTO `pipeline_smw_atts2` VALUES (59,52,'2011/3/28T21:22:31',2455649.3906366,''),(55,54,'JLM',0,''),(55,52,'2011/3/28T21:30:05',2455649.3958912,''),(51,52,'2011/3/31T18:30:16',2455652.2710185,''),(53,52,'2011/3/31T18:30:16',2455652.2710185,''),(58,52,'2011/3/31T18:30:17',2455652.2710301,''),(54,52,'2011/3/31T18:30:16',2455652.2710185,'');
/*!40000 ALTER TABLE `pipeline_smw_atts2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_conc2`
--

DROP TABLE IF EXISTS `pipeline_smw_conc2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_conc2` (
  `s_id` int(8) unsigned NOT NULL,
  `concept_txt` mediumblob,
  `concept_docu` mediumblob,
  `concept_features` int(11) DEFAULT NULL,
  `concept_size` int(11) DEFAULT NULL,
  `concept_depth` int(11) DEFAULT NULL,
  `cache_date` int(8) unsigned DEFAULT NULL,
  `cache_count` int(8) unsigned DEFAULT NULL,
  PRIMARY KEY (`s_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_conc2`
--

LOCK TABLES `pipeline_smw_conc2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_conc2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_conc2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_conccache`
--

DROP TABLE IF EXISTS `pipeline_smw_conccache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_conccache` (
  `s_id` int(8) unsigned NOT NULL,
  `o_id` int(8) unsigned NOT NULL,
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_conccache`
--

LOCK TABLES `pipeline_smw_conccache` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_conccache` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_conccache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_ids`
--

DROP TABLE IF EXISTS `pipeline_smw_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_ids` (
  `smw_id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `smw_namespace` int(11) NOT NULL,
  `smw_title` varbinary(255) NOT NULL,
  `smw_iw` varbinary(32) DEFAULT NULL,
  `smw_sortkey` varbinary(255) NOT NULL,
  PRIMARY KEY (`smw_id`),
  KEY `smw_title` (`smw_title`,`smw_namespace`,`smw_iw`),
  KEY `smw_sortkey` (`smw_sortkey`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_ids`
--

LOCK TABLES `pipeline_smw_ids` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_ids` DISABLE KEYS */;
INSERT INTO `pipeline_smw_ids` VALUES (1,102,'Has_type',':smw-preprop','Has_type'),(2,102,'Equivalent_URI',':smw-preprop','Equivalent_URI'),(4,102,'_INST',':smw-intprop','_INST'),(7,102,'Display_units',':smw-preprop','Display_units'),(8,102,'Imported_from',':smw-preprop','Imported_from'),(12,102,'Corresponds_to',':smw-preprop','Corresponds_to'),(13,102,'Provides_service',':smw-preprop','Provides_service'),(14,102,'Allows_value',':smw-preprop','Allows_value'),(15,102,'_REDI',':smw-intprop','_REDI'),(17,102,'Subproperty_of',':smw-preprop','Subproperty_of'),(18,102,'Subcategory_of',':smw-preprop','Subcategory_of'),(19,102,'_CONC',':smw-intprop','_CONC'),(20,102,'Has_default_form',':smw-preprop','Has_default_form'),(21,102,'Has_alternate_form',':smw-preprop','Has_alternate_form'),(22,102,'Has_improper_value_for',':smw-preprop','Has_improper_value_for'),(23,102,'_1',':smw-intprop','_1'),(24,102,'_2',':smw-intprop','_2'),(25,102,'_3',':smw-intprop','_3'),(26,102,'_4',':smw-intprop','_4'),(27,102,'_5',':smw-intprop','_5'),(28,102,'Has_fields',':smw-preprop','Has_fields'),(50,0,'',':smw-border',''),(51,6,'SemanticBiology_Add.png','','SemanticBiology Add.png'),(52,102,'Modification_date',':smw-preprop','Modification date'),(53,6,'SemanticBiology_Warning.png','','SemanticBiology Warning.png'),(54,102,'Initials','','Initials'),(55,2,'Jmuhlich','','Jmuhlich'),(56,10,'Categoryhelper_table_end','','Categoryhelper table end'),(57,10,'Import_generated_content','','Import generated content'),(58,6,'Test.png','','Test.png'),(59,0,'Main_Page','','Main Page');
/*!40000 ALTER TABLE `pipeline_smw_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_inst2`
--

DROP TABLE IF EXISTS `pipeline_smw_inst2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_inst2` (
  `s_id` int(8) unsigned NOT NULL,
  `o_id` int(8) unsigned DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_inst2`
--

LOCK TABLES `pipeline_smw_inst2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_inst2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_inst2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_redi2`
--

DROP TABLE IF EXISTS `pipeline_smw_redi2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_redi2` (
  `s_title` varbinary(255) NOT NULL,
  `s_namespace` int(11) NOT NULL,
  `o_id` int(8) unsigned DEFAULT NULL,
  KEY `s_title` (`s_title`,`s_namespace`),
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_redi2`
--

LOCK TABLES `pipeline_smw_redi2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_redi2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_redi2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_rels2`
--

DROP TABLE IF EXISTS `pipeline_smw_rels2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_rels2` (
  `s_id` int(8) unsigned NOT NULL,
  `p_id` int(8) unsigned NOT NULL,
  `o_id` int(8) unsigned DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `p_id` (`p_id`),
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_rels2`
--

LOCK TABLES `pipeline_smw_rels2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_rels2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_rels2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_spec2`
--

DROP TABLE IF EXISTS `pipeline_smw_spec2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_spec2` (
  `s_id` int(8) unsigned NOT NULL,
  `p_id` int(8) unsigned NOT NULL,
  `value_string` varbinary(255) DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `p_id` (`p_id`),
  KEY `s_id_2` (`s_id`,`p_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_spec2`
--

LOCK TABLES `pipeline_smw_spec2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_spec2` DISABLE KEYS */;
INSERT INTO `pipeline_smw_spec2` VALUES (54,1,'_str');
/*!40000 ALTER TABLE `pipeline_smw_spec2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_subp2`
--

DROP TABLE IF EXISTS `pipeline_smw_subp2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_subp2` (
  `s_id` int(8) unsigned NOT NULL,
  `o_id` int(8) unsigned DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_subp2`
--

LOCK TABLES `pipeline_smw_subp2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_subp2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_subp2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_subs2`
--

DROP TABLE IF EXISTS `pipeline_smw_subs2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_subs2` (
  `s_id` int(8) unsigned NOT NULL,
  `o_id` int(8) unsigned DEFAULT NULL,
  KEY `s_id` (`s_id`),
  KEY `o_id` (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_subs2`
--

LOCK TABLES `pipeline_smw_subs2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_subs2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_subs2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_smw_text2`
--

DROP TABLE IF EXISTS `pipeline_smw_text2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_smw_text2` (
  `s_id` int(8) unsigned NOT NULL,
  `p_id` int(8) unsigned NOT NULL,
  `value_blob` mediumblob,
  KEY `s_id` (`s_id`),
  KEY `p_id` (`p_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_smw_text2`
--

LOCK TABLES `pipeline_smw_text2` WRITE;
/*!40000 ALTER TABLE `pipeline_smw_text2` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_smw_text2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_tag_summary`
--

DROP TABLE IF EXISTS `pipeline_tag_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_tag_summary` (
  `ts_rc_id` int(11) DEFAULT NULL,
  `ts_log_id` int(11) DEFAULT NULL,
  `ts_rev_id` int(11) DEFAULT NULL,
  `ts_tags` blob NOT NULL,
  UNIQUE KEY `tag_summary_rc_id` (`ts_rc_id`),
  UNIQUE KEY `tag_summary_log_id` (`ts_log_id`),
  UNIQUE KEY `tag_summary_rev_id` (`ts_rev_id`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_tag_summary`
--

LOCK TABLES `pipeline_tag_summary` WRITE;
/*!40000 ALTER TABLE `pipeline_tag_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_tag_summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_templatelinks`
--

DROP TABLE IF EXISTS `pipeline_templatelinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_templatelinks` (
  `tl_from` int(10) unsigned NOT NULL DEFAULT '0',
  `tl_namespace` int(11) NOT NULL DEFAULT '0',
  `tl_title` varbinary(255) NOT NULL DEFAULT '',
  UNIQUE KEY `tl_from` (`tl_from`,`tl_namespace`,`tl_title`),
  UNIQUE KEY `tl_namespace` (`tl_namespace`,`tl_title`,`tl_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_templatelinks`
--

LOCK TABLES `pipeline_templatelinks` WRITE;
/*!40000 ALTER TABLE `pipeline_templatelinks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_templatelinks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_text`
--

DROP TABLE IF EXISTS `pipeline_text`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_text` (
  `old_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `old_text` mediumblob NOT NULL,
  `old_flags` tinyblob NOT NULL,
  PRIMARY KEY (`old_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=binary MAX_ROWS=10000000 AVG_ROW_LENGTH=10240;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_text`
--

LOCK TABLES `pipeline_text` WRITE;
/*!40000 ALTER TABLE `pipeline_text` DISABLE KEYS */;
INSERT INTO `pipeline_text` VALUES (1,'\'\'\'MediaWiki has been successfully installed.\'\'\'\n\nConsult the [http://meta.wikimedia.org/wiki/Help:Contents User\'s Guide] for information on using the wiki software.\n\n== Getting started ==\n* [http://www.mediawiki.org/wiki/Manual:Configuration_settings Configuration settings list]\n* [http://www.mediawiki.org/wiki/Manual:FAQ MediaWiki FAQ]\n* [https://lists.wikimedia.org/mailman/listinfo/mediawiki-announce MediaWiki release mailing list]','utf-8'),(2,'SemanticBiology \"add\" icon','utf-8'),(3,'SemanticBiology \"warning\" icon','utf-8'),(4,'A user\'s initials.  Used to create SUID page titles.  Its type is [[has type::type:string|string]].','utf-8'),(5,'Initials: [[initials::JLM]]','utf-8'),(6,'A user\'s initials.  Used to create SUID page titles.  Its type is [[has type::type:string|string]].','utf-8'),(7,'<noinclude>Used as a final, hidden template to close out infoboxes.</noinclude><includeonly>|}</includeonly>','utf-8'),(8,'<noinclude>Used to provide a hidden form field where SBWiki importer tools can place automatically generated content.</noinclude><includeonly>{{{content|}}}</includeonly>','utf-8'),(9,'Add button','utf-8'),(10,'Warning icon','utf-8'),(11,'testing','utf-8');
/*!40000 ALTER TABLE `pipeline_text` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_trackbacks`
--

DROP TABLE IF EXISTS `pipeline_trackbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_trackbacks` (
  `tb_id` int(11) NOT NULL AUTO_INCREMENT,
  `tb_page` int(11) DEFAULT NULL,
  `tb_title` varbinary(255) NOT NULL,
  `tb_url` blob NOT NULL,
  `tb_ex` blob,
  `tb_name` varbinary(255) DEFAULT NULL,
  PRIMARY KEY (`tb_id`),
  KEY `tb_page` (`tb_page`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_trackbacks`
--

LOCK TABLES `pipeline_trackbacks` WRITE;
/*!40000 ALTER TABLE `pipeline_trackbacks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_trackbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_transcache`
--

DROP TABLE IF EXISTS `pipeline_transcache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_transcache` (
  `tc_url` varbinary(255) NOT NULL,
  `tc_contents` blob,
  `tc_time` binary(14) NOT NULL,
  UNIQUE KEY `tc_url_idx` (`tc_url`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_transcache`
--

LOCK TABLES `pipeline_transcache` WRITE;
/*!40000 ALTER TABLE `pipeline_transcache` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_transcache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_updatelog`
--

DROP TABLE IF EXISTS `pipeline_updatelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_updatelog` (
  `ul_key` varbinary(255) NOT NULL,
  PRIMARY KEY (`ul_key`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_updatelog`
--

LOCK TABLES `pipeline_updatelog` WRITE;
/*!40000 ALTER TABLE `pipeline_updatelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_updatelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_user`
--

DROP TABLE IF EXISTS `pipeline_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_name` varbinary(255) NOT NULL DEFAULT '',
  `user_real_name` varbinary(255) NOT NULL DEFAULT '',
  `user_password` tinyblob NOT NULL,
  `user_newpassword` tinyblob NOT NULL,
  `user_newpass_time` binary(14) DEFAULT NULL,
  `user_email` tinyblob NOT NULL,
  `user_options` blob NOT NULL,
  `user_touched` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `user_token` binary(32) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `user_email_authenticated` binary(14) DEFAULT NULL,
  `user_email_token` binary(32) DEFAULT NULL,
  `user_email_token_expires` binary(14) DEFAULT NULL,
  `user_registration` binary(14) DEFAULT NULL,
  `user_editcount` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_name` (`user_name`),
  KEY `user_email_token` (`user_email_token`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_user`
--

LOCK TABLES `pipeline_user` WRITE;
/*!40000 ALTER TABLE `pipeline_user` DISABLE KEYS */;
INSERT INTO `pipeline_user` VALUES (1,'WikiSysop','',':B:ce7490c4:99b97920da11150bc44a078fe5caa35f','',NULL,'','','20110328212925','544390599c9b00909073447ae12911a7',NULL,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',NULL,'20110328212230',3),(2,'Ontologybot','',':B:fe96d3ba:c5874d26afe399114d91f5f37513ad03','',NULL,'jeremy_muhlich@hms.harvard.edu','','20110328212647','00138cb4cbf245d9aff9febf821cf12c',NULL,'7bc59f6f73c60ba6fc46af8f14b72ea5','20110404212559','20110328212558',0),(3,'Jmuhlich','',':B:a4633346:f6a83c0f9d35e82c2ff45b83531a03fa','',NULL,'jeremy_muhlich@hms.harvard.edu','','20110331183022','a5dffcdb358ccfbffe2fd93188d48c0d',NULL,'56b6d3f468786d6ef1de13ad532933be','20110404212615','20110328212615',7);
/*!40000 ALTER TABLE `pipeline_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_user_groups`
--

DROP TABLE IF EXISTS `pipeline_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_user_groups` (
  `ug_user` int(10) unsigned NOT NULL DEFAULT '0',
  `ug_group` varbinary(16) NOT NULL DEFAULT '',
  UNIQUE KEY `ug_user_group` (`ug_user`,`ug_group`),
  KEY `ug_group` (`ug_group`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_user_groups`
--

LOCK TABLES `pipeline_user_groups` WRITE;
/*!40000 ALTER TABLE `pipeline_user_groups` DISABLE KEYS */;
INSERT INTO `pipeline_user_groups` VALUES (2,'bot'),(1,'bureaucrat'),(3,'bureaucrat'),(1,'sysop'),(2,'sysop'),(3,'sysop');
/*!40000 ALTER TABLE `pipeline_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_user_newtalk`
--

DROP TABLE IF EXISTS `pipeline_user_newtalk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_user_newtalk` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `user_ip` varbinary(40) NOT NULL DEFAULT '',
  `user_last_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  KEY `user_id` (`user_id`),
  KEY `user_ip` (`user_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_user_newtalk`
--

LOCK TABLES `pipeline_user_newtalk` WRITE;
/*!40000 ALTER TABLE `pipeline_user_newtalk` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_user_newtalk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_user_properties`
--

DROP TABLE IF EXISTS `pipeline_user_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_user_properties` (
  `up_user` int(11) NOT NULL,
  `up_property` varbinary(32) NOT NULL,
  `up_value` blob,
  UNIQUE KEY `user_properties_user_property` (`up_user`,`up_property`),
  KEY `user_properties_property` (`up_property`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_user_properties`
--

LOCK TABLES `pipeline_user_properties` WRITE;
/*!40000 ALTER TABLE `pipeline_user_properties` DISABLE KEYS */;
INSERT INTO `pipeline_user_properties` VALUES (3,'rememberpassword','1');
/*!40000 ALTER TABLE `pipeline_user_properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_valid_tag`
--

DROP TABLE IF EXISTS `pipeline_valid_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_valid_tag` (
  `vt_tag` varbinary(255) NOT NULL,
  PRIMARY KEY (`vt_tag`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_valid_tag`
--

LOCK TABLES `pipeline_valid_tag` WRITE;
/*!40000 ALTER TABLE `pipeline_valid_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_valid_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_watchlist`
--

DROP TABLE IF EXISTS `pipeline_watchlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pipeline_watchlist` (
  `wl_user` int(10) unsigned NOT NULL,
  `wl_namespace` int(11) NOT NULL DEFAULT '0',
  `wl_title` varbinary(255) NOT NULL DEFAULT '',
  `wl_notificationtimestamp` varbinary(14) DEFAULT NULL,
  UNIQUE KEY `wl_user` (`wl_user`,`wl_namespace`,`wl_title`),
  KEY `namespace_title` (`wl_namespace`,`wl_title`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_watchlist`
--

LOCK TABLES `pipeline_watchlist` WRITE;
/*!40000 ALTER TABLE `pipeline_watchlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_watchlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profiling`
--

DROP TABLE IF EXISTS `profiling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profiling` (
  `pf_count` int(11) NOT NULL DEFAULT '0',
  `pf_time` float NOT NULL DEFAULT '0',
  `pf_memory` float NOT NULL DEFAULT '0',
  `pf_name` varchar(255) NOT NULL DEFAULT '',
  `pf_server` varchar(30) NOT NULL DEFAULT '',
  UNIQUE KEY `pf_name_server` (`pf_name`,`pf_server`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profiling`
--

LOCK TABLES `profiling` WRITE;
/*!40000 ALTER TABLE `profiling` DISABLE KEYS */;
/*!40000 ALTER TABLE `profiling` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-04-11 16:33:00
