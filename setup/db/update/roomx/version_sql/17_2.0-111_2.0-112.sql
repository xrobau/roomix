UPDATE `roomx`.`config` SET `vat_1` = '20', `vat_2` = '7', `version` = '2.0-112' WHERE CONVERT( `config`.`o_m` USING utf8 ) = 'Hotel' LIMIT 1 ;
ALTER TABLE `models` CHANGE `room_model` `room_model` VARCHAR( 40 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL 