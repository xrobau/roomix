CREATE DATABASE IF NOT EXISTS roomx;
USE roomx; 

CREATE TABLE IF NOT EXISTS calendar (datefield DATE);

DROP PROCEDURE IF EXISTS `fill_calendar`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `fill_calendar`(start_date DATE, end_date DATE)
BEGIN
  DECLARE crt_date DATE;
  SET crt_date=start_date;
  WHILE crt_date < end_date DO
    INSERT INTO calendar VALUES(crt_date);
    SET crt_date = ADDDATE(crt_date, INTERVAL 1 DAY);
  END WHILE;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS `booking` (
  `id` int(10) NOT NULL auto_increment,
  `room_id` varchar(20) NOT NULL,
  `guest_id` varchar(30) NOT NULL,
  `date_ci` datetime NOT NULL,
  `date_co` datetime NOT NULL,
  `num_guest` int(2) NOT NULL default '1',
  KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

CREATE TABLE IF NOT EXISTS `calendar` (
  `datefield` date default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `config` (
  `o_m` varchar(10) NOT NULL default 'Hotel',
  `locked` tinyint(1) NOT NULL default '1',
  `cbr` tinyint(1) NOT NULL default '1',
  `rmbc` tinyint(1) NOT NULL default '1',
  `reception` varchar(5) NOT NULL,
  `company` varchar(512) NOT NULL,
  `clean` varchar(6) NOT NULL,
  `minibar` varchar(6) NOT NULL,
  `logo` varchar(100) NOT NULL,
  `logo64` mediumtext NOT NULL,
  `vat_1` decimal(5,2) NOT NULL default '19.60',
  `vat_2` decimal(5,2) NOT NULL default '5.50',
  `mail` varchar(50) NOT NULL,
  `version` varchar(10) NOT NULL,
   UNIQUE KEY `o_m` (`o_m`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `guest` (
  `id` int(10) NOT NULL auto_increment,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `address` varchar(60) NOT NULL,
  `cp` varchar(15) NOT NULL,
  `city` varchar(20) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `fax` varchar(15) NOT NULL,
  `mail` varchar(30) NOT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

CREATE TABLE IF NOT EXISTS `minibar` (
  `digit` int(1) NOT NULL,
  `label` varchar(50) NOT NULL,
  `price` decimal(8,2) NOT NULL,
  `vat` decimal(5,2) NOT NULL default '0.00'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `models` (
  `room_model` varchar(20) NOT NULL,
  `room_price` decimal(6,2) NOT NULL default '0.00',
  `room_guest` decimal(6,2) NOT NULL default '0.00',
  `room_vat` decimal(5,2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rate` (
  `name` varchar(20) NOT NULL,
  `prefix` varchar(20) NOT NULL,
  `rate` decimal(8,5) NOT NULL default '0.00000',
  `rate_offset` decimal(8,5) NOT NULL default '0.00000'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `register` (
  `id` int(11) NOT NULL auto_increment,
  `room_id` varchar(15) NOT NULL,
  `guest_id` varchar(10) NOT NULL,
  `num_guest` int(1) NOT NULL default '1',
  `date_ci` datetime NOT NULL,
  `date_co` datetime NOT NULL,
  `status` tinyint(1) NOT NULL,
  `billing_file` varchar(100) NOT NULL,
  `paid` tinyint(1) NOT NULL,
  `total_room` decimal(10,2) NOT NULL,
  `total_bar` decimal(10,2) NOT NULL,
  `total_call` decimal(10,2) NOT NULL,
  `total_billing` decimal(10,2) NOT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=24 ;

CREATE TABLE IF NOT EXISTS `rooms` (
  `id` int(11) NOT NULL auto_increment,
  `room_name` varchar(20) NOT NULL,
  `guest_name` varchar(60) NOT NULL,
  `model` varchar(20) NOT NULL,
  `extension` varchar(5) NOT NULL,
  `groupe` varchar(20) NOT NULL,
  `free` tinyint(1) NOT NULL default '1',
  `clean` tinyint(1) NOT NULL default '1',
  `mini_bar` varchar(100) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

CREATE TABLE IF NOT EXISTS `status` (
  `date` date NOT NULL,
  `free` int(4) NOT NULL,
  `busy` int(4) NOT NULL,
  `booking` int(4) NOT NULL,
  UNIQUE KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT IGNORE INTO `config` (`o_m`, `locked`, `cbr`, `rmbc`, `reception`, `company`, `clean`, `minibar`, `logo`, `logo64`, `vat_1`, `vat_2`, `mail`, `version`) VALUES
('Hotel', 1, 1, 1, '100', 'Hotel California\r\n56 Route de Vannes\r\n56400 La Roche Bernard\r\nTel : (33)297565656\r\nEmail: hotel.california@orange.fr', '*36', '*37', 'modules/rx_general/images/logo-roomx.png', 'data:image/png;base64,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qKysLB6PP//88w8//PDy5cuzs7P1h0mSVF1d/Z3vfAdjvHjx4paWlv37969Zs+a+++5jXyrd09raunbt2pkzZ06bNq2pqemll17atGnTRRddRDvCaVs0Gj1x4sRNN900d+7cBQsWtLS07Nmz5+c///nq1atNsxEeeuih6urqoqIieqFEIvHyyy8fP3489bl1zTXX5ObmTps2jeZjchx34MCBtWvX3nbbbRostQ/6coVae0pqj6DyvJamK1tskiTRA7rOVn3m/X8PjLsaTKBdcdR95b3MgJ+6pq0c1Ab52RDgYAPR8bJOpbhh+PvZBEGYPXv2vHnz5syZU1xc/PDDDxcWFp49e9aQUUQIKSkpWbZsWUVFRX9/P4w59ov+vKen53Of+9zFF1+8cOFCVVVffvnll19++brrrsvKyjK9z1deeSUSiRw8eDA3N3ft2rUvvfTS5s2bTdEbDAYrKiouvPDCqVOndnZ27tmzp6Wl5ZprrvH5fIYzO53OioqKysrKvr6+mpoaeuabb755586dpvNp5syZkUiEYoOaDEpKSr7//e+nOLeOHj3a29ubl5f3yiuvaOmWPT09s2fPBiYb3LRaKltvACxiNg3Hc4IYwxPShrzdX56RkQG6SqZsri8bN6pHr2mJHFMZ+1MAJ7Gvbty4saampqamRhAEPYZlWaatGL74xS9CsrTeFLdbb7116tSpgUBAUZTNmzdv2rSJ1tmyCiMBgF27doVCofr6ekmSVq9e/fDDD2/dutXgiWlra1u9evWaNWuys7N5nv/www9ffPFFQ5E61rX43HPPHT16lAYnfv3rX//e9763Z88ednWgfac++uij3bt3U7wtXrz4qaeeqqmpSWXN2rp1a3l5+d69e+vr67V7TiQS6enprG3G4CABs7IhSQOzNfoSHM44EifCBq2m5xqk5REVwdHHcnzyAvM/DoDpa87IyHj77bf37dvX1NRkGG5ZlmfMmOH1eqkmPEab809/+tOBgYHS0lJCSHV19Q033LBs2TL72Gn67ZNPPnn8+HHqO7n++uvvvffe3t5efYDO73//+7lz5+bk5BBCjh8/Pn/+/JkzZ9rMBnrmQCBw3333vfrqq1QIvOSSSx566CFTTy9CKBaLVVZWxuNxKtled911999/f9L1MRwOP/fcc06ns7q6+pJLLmEfzTQlHazLA4FZ7gRrPxskRkFIwPgDWFUB0vPoZa2SQKz26OvJmNaN+qug4O8YwNpo7tmz58CBA+Fw2ODJVFW1vLx81qxZ69ato9avUfAwQqilpWXTpk0rVqyg1sWGhoZ/+7d/S+oSoDeTn58/Y8YMqs8jhFasWLFhwwbtlff09Dz99NPUJ8Rx3I4dO37xi19AavGV69ata25uDofDAOD3+9va2l544QVTWUMQhNWrVx8+fFgQBFVVs7KyWltbq6qqkkocy5Yt2759+7PPPmuo0W2/2LFx72z5S9PqX8McCtGIm0TGH8AESHq+vhmD3mlkFa9myO/VsiYnwi30TwRgbWSzs7M3bdq0efNm2vFM/208HqeC7k033cQu9ilu27ZtW758udZvye/3Z2Zmpnh7tNVTQ0MDdZAUFhYeP348FArRU/3yl78sLS2llrb29vbi4mKanJyiWn7PPfdUVlbSf65YsYI2nTEN3rjhhhva2tq6urroLCwpKaErhdW19u7de+zYsbS0tEsvvXTx4sUGg2KKCk7SAbeqbYYQiof70lVpgiYNjeZgM/5M1xRTR9EYU8c/BbARwwsWLNixY8cf//hHA9NSHl64cGEwGKSRlSPVh2VZrqqqys3NpYuuLMuCIGRkZKT+8pYuXVpfX68F6HV0dASDQfrzxx9/vLy8nN7P2bNn6SqTYmlOAPjc5z5HdQeqTaSnp1M8mx7/9NNPv/jii3SBmz59+vbt26uqqkxbq6mq+otf/GLNmjUnT568++67rZo5mvKqaScX+wK6JoUBEcbdta4JsGFhBKi/DTGUyyrwwPTEtYk5/xTA44Dh+fPnP/roo2+++aamouj9Opdffnk8Hv/Wt741Uh5OJBJ1dXWCINC3293dXVhYOKLbKysra2lp0Yw3BQUF+/fvB4Da2tqsrCy3262FcFC3aurK+aRJk6jThYY6zZ49+5133rFahubNm7dixYrq6mo6NdevX3/jjTeCWQj+qVOngsGgJEmFhYXTp09PXWy2aSvLfsuWENG+SxDkaj4kChMwVTCgUIdWp8OqklHSR/7byYH5RwCwNgOuu+6666+/fsuWLRRv+mU+Ho8vWrTo6NGjd91114iGXlGUcDiswS8cDgcCgRHdW0ZGhma4AgCPx9PQ0AAAzc3NWVlZmhM7Eonk5eWNVEz1eDya6zUzM7OpqcnmJ/fee29tbS0FcFZWlt/vf+GFF1hSfeihh+bMmfPCCy888MADNsUSTJnWkPVq06PUqoI8wlxnY92Fof0whpLRNuKzs7NSGV4u06pqin1iJkxAaYp/XgBrs+fuu+/+7Gc/++abbwKTN4MQWrly5Z49ex544IHURSBCSCwW0wAciURSVID1WyRyzh7jcDgogNva2jwej3YbAwMD+iDHFB/Z4XBoeQV+v7+jo8Pm+JkzZxYVFXV3d2OMZVleuHDhtm3bNN2eTs1jx4699dZbvb29l1122axZs2xSuA2d2fQyJzCdR8GsuSFbdYgQIqngPP5/k7xAYAKykRDk9lT29/bovdZWy40e3mzAn0HA/hTA44bhRx55ZMaMGUeOHNEmtzbQiURi7dq1e/bseeSRR1LHsJZJA7oYoxFt+jPokay37hoy5lMX50Z0/E9+8pMtW7ZQhdzpdDY1Ne3evVvvFLn11luvu+66ysrKjRs36mew1UVNOw8b0KsVmjV8y/YlBULC3a3n938AABNUl8PHQ/zoawTzYNZ63kaBN62j/FeXpf+hAKwN6+OPP97Q0PDxxx/rmwlrFRKXL1++adOmxx57LJWh5zjO4/FovTPdbncwOLJcc0VRfD6fdhuxWGzy5MkAUFRU1N/fr60jLperp6dnpJpYJBLR6s51d3fbczghZMqUKbfddtu+ffuoSHLxxRffcMMN2uC8/PLLfr8/kUisX7+eBoFYmbVNK79rVWatuoFrmwG357J5EOIPPTeFdE1QMjAhACIUHv7fUDSeomjABuqyVlJ9x8ZPmJPxBIwRGcuRY1/P6GkPHjzY1tZWXV1tyC+n57/55ptp9+CkN4wxzsjI0N5QUjGV3bq7u71er3aVvr6+adOmAUBJSUlzc7OmZKanp1PRekRbNBrVpMHOzs6SkpKkq9uGDRuamppisRghxOfznXfeeT/96U/pPH722WcXLVr00UcfXX/99aamKYPNyarBNwtmLRxa/08DaQPmG4+8t7jlJYGfqFR+etrJcpv08WsEkOlyAxaFEKxaXmtuZIP+//cKYEODSfuar6ZWX5sujKnfAABs27btxIkT/f39bElKWZbXrFnz2GOPvfzyy/aytMPhmDJlSjwe10KgOjs7RyTrHj58OC8vT2OqYDC4aNEiAPD5fDk5OW1tbfTMubm5b7zxxoge89SpUy6Xi/5cEIQjR45cc801SZc2jPGXvvSlmpoajLEkSUuXLn3ttdc6OzuPHz9eU1Nz+vTpZcuWTZ061SbAyLRvOAwvl6MBm9rJVbNNv58QaKmvWXzkF7nuiZ3xhACHiO/YNjkeNTwCa1HTHoR9dtOqdKxJbKLZGI+F5QzvTFtiRyQEGt56OBwWRdG0JgvN6U2F6ulQ5uTkPPfcc88++6xeUtW+5Xn+6quvvv3223fs2GGDYYzxkiVLqqqqtPjkSCQSDAZTf8z33nuvtLSUCuGyLBcUFGhZCj/4wQ8OHTpE76ewsPDPf/7ziMb/mWeeoW0laEy13+/Pzc1NWoaamuupP4lueXl5b7zxxi233HL++ee///77v/71rw1ddtmTsEw7HI3DKJfdr5eoiaoSgFBvR/57G0qdA2Oc8DpvlCUJIwSTGt/vO/oGIEyIaurxYnUEGyrWD5RWl2NEWPhEAcw2cTf4wdFoN2qbtYpGcrvd/f399gRuYNqpU6fu2LFj165dsViM/ZZmAvznf/7n66+/boPhq666qrKyMhKJaP6eurq6FAtoxmKxU6dO5eTkqKrK83xlZeWSJUvS0tLoAf/yL/8SDodplHJmZmY8Hj98+HDqqv6WLVuoNE7r+Gm59az0awhCyMvLW79+/c6dO2kSyMyZMx944AFBEFpaWn71q1+BaXCF2bJrUGgN+62Il3517g4x197W6nzlvouUkzA2yzPVnGMSqKrdeQiAU4CCHf/Z3dYEiNMvNFa2cfZJDVqxqdcjxeL+nzSA9WmfhvgyQ4T6iDb6q5MnTxYWFrILv6qqgUDg7NmzbJsCK7Gcfi4rK3v44Yf/8pe/6J3D2lNwHLd69eqvfOUrx48ft8Kw2+1+6qmnnn32WWq8nTZt2ve//31Iod0RQqiqqqqtrY3+sL+/f9++fd/+9rf1K8hdd9119OhRjuMkSbrqqqu+973vpfgWHnzwwQULFtCyuF1dXcuXL1+0aJHpdKFOIwPJ3HvvvW1tbR0dHdQXVVFRsWrVKlVVV69eTdGlf8tWIjRrndJwq+m6sixrmcD0sz43WFXV9pbG7Je/dRmc4rixOn4RgqgELxV9uUrNtiFhIAAI8vGAf8vt4WCP9gimq5JeV2efHczK6OvrmbDFlf9qAGbFKn1Cll5tGKksrZ28v78/GAympaWxv1UUpaio6L333tOD077/iHY/V1555Ve+8pUtW7YYgvIHyyC6XDfeeOOVV175pz/9ybRBDCFk2bJla9euPXDgAMZ48uTJHR0dv/3tb5OmHLS3t996660VFRU0AuTVV1996623YHgA0E033STLcmVlJUIoKytLluUXX3zRCjbavDl27Ngrr7xCy+IGg8EPPvjgW9/6FisE9ff3i6Lo8Xg6OzuB6Wb4+9///uDBg3SIzjvvvDNnzixfvpyK99pbph8MsdBWcDWAk8JVL07rc/oJIQrgjpoTvle+e5HQMBhDOYauSAAwIMM7k29IX/r56ilrZMnybHQ/ASgOnUIvficaicBQioKNQY4NSmEbvrF+Y0OT5HGPwcQjIl7TzkZWsnSKS44+c/o73/kOlZ9ZbKiqOmPGjKeeeopG8NqIKKZ9Fb75zW/ec88927dvZ0dQVVWXy3Xbbbc9+uijd9xxB1gkZ2/YsCEjI+Odd97heX7NmjVbtmz52c9+ZiVkAkBlZeWVV165dOnSvLy8aDRK68izqYKCIDz//POEkP3792OML7jggh/84AePP/64aT8k+jh79uy54YYbLr74YkJIS0vL888//9xzz9GYR8PxbW1tgiD4fL7m5mbDm1IUZdGiRT6fL5FIUMV+9+7d3/rWtyi09G9WkqRoNKrdj8vlooqMQbOlKDWIzbIsK7pN/1VMVut2/nHeG/9+EZwBNA6Sc18Udkz5Kiy5jUeEn31ZG+ezn3oIAcIwre61xLPfjMigfxz9B3b1tBdJDJPTsG6OO4bxiIiXbZeoZ1rTdiemhi76K0mSuru7T548uXXr1ptuusnr9ba1tS1YsMDq8URRvPjii5cvX7548eJHH3103759bW1tvb29kiRZ8YN+Eb311luXLl164MABQ1gFfRBRFFevXh0KhdLS0r72ta+99957ra2t1NdCN1EUN2/eXFJS8vTTTw8MDKxcufKll15atWrVyZMn4/E4rQUjy3I8Ho9EIv/93/996aWXrlq1Kisrq7Ky8qmnntq6dSslTFZMSEtL+8Mf/uByuXbs2MFx3Pr16x9//PFrr722qakpkUhQqUFV1UQi0d3dfc8993zhC19Yu3atz+c7derUgQMHjh49OmXKFL24S9f7WCz2zDPP+P3+goKCjz/+uLu7WzuVZmC/8cYbd+/eLYri66+//tvf/paqxHrOkWW5vr5eCyZVVTUnJ+f9999PJBKs+YplWm2n9pfuHQiHGrf++Kozvy4RQjA26AIAAuiVxV2z7/Iuvk7gMcdxgj+vavJVxNaaRUmY42FW42vx5++VJNneEwZMKKiebNlwLn3Alj5pcZybTqeYvMaGfbNxoSzlsiuQtvxwHPfWW2+tW7duwYIFfr8/Jydn6tSpNN3H3isrCEJra2tLS0tXV1coFKqqqnriiSfWrVunF1ps2P7mm29uampatWqV6QE8zyuKcubMmebm5rq6uttuu+273/2uwY387rvvPvbYYzU1NeXl5TzPnzp1Kj8/Py8vz+12S5LU09NTVVWVn58/efLk06dP9/b2Llu27Mc//rHL5bJpjEL3P//885s3b+7q6iovL5dl+eOPP541a1ZmZqbT6YzH411dXTU1NZMmTZo8efLx48clSVqyZMkDDzzgdDr1Sk1lZeUzzzw9AWtyAAAcE0lEQVQTj8f37ds3ffr02bNnq6p67NixcDhcWlrqcDjuv/9+rYAJz/MVFRUzZszo7e19/fXXaeErulo999xzx44do1WBli5dqsWiEELefPPN0tJSr9d7wQUXXHHFFYZ5TzncFNIAEI4l2o6+G/jg8cWJqhS7byfZZKjEeZULv5lWuoQjCh4qJRmNJ/L+/PXz5Gp7kqI3EFegdvHd7qvupSlQbKHZ1Jsh2bezH1Hz7nEAMNuD2DSgzNQCbNXCWwPwjh07Vq9ePfZFaOvWrevXr7fq66G3GFFd+rbbbnv66adTNBT96Ec/MiwNtMZFa2vrQw899MwzzxQWFubl5aWnp7vd7oGBgXA4PDAwUFVVVVRUdM8991x77bVpaWn2nm394hiLxaqrq3/4wx/u3LmzuLg4KysrIyPD4XDQ04ZCoTNnzsyZM+fb3/72qlWrvF4v6Eq60kKtv/vd7770pS/ZXI5aGbQxaWhooLb6Sy+9VIOo0+m8+OKL33//ffvxWbdu3eOPP25QGq2cvQShs3Vno9s3rIjt9fEKQjDGVsA0sXcPP6//ygdd/hw0/B1hjuvraJn70i3FQpQgO5onBBCADFBXcBl3yyb6vkw7eoN1+Q7WtmKoF23a0XvsGE4OYDBL+LShaHsLu4HuxkuQ0EpeGNYL01XGNDLZajPYw/VSEP189OjRAwcO1NXVdXV1ZWZmFhYWTp06VSvmqg/Es3d66aUM+mHv3r2HDx+ur6+nleUmTZo0ffr0FStWaFY90x5FSZ+O2pYMugktfKcX7zVfl82wxGKxcDhskDYNviJVVWUVQj0dHfv/MvXQ/5R7YjBO0O1ThYOB5bEr7k1PcxlMwZoRuL9yX8Xe+wMoYn/FwW9VaPDNlT7/W09JGe14Zij1bo9em76Epm20YTziDpG901/zJeg7ZdjYxE336KsosRNupB4ssOghALbN+0xLKCTNOLcShKy+ZVc0+4NtrBraks9a401r05o+sqlMZOrgtfKU2OcPmUJXj2FOEJvbOjr3/mla9Z9KE3UeUYeWsaBXgY9RQcuF/+6YuczJm3Rg0/6qgMKHXq3Y+0OfizqPkm0KBB3+9uX/6b3sDmE4hpNW0rTHsIGZx6vBShIG1lRwK3bVFwdi0zgM/GP4Z+q2OH2Re1PpXc9dbOZXiiuCTT/ekQI4Rb417aOTSpyZvneJfaqQ4a2ZfmBxa3D1GyyRLIBN0RsOD1S+saXoxNNLnR0CPzbcAsDQzyMJeDPjUvHq+31ejxVUhu3EXPfJvee9c282jiSV2+m3kgJ1C7/u/dx9vCCwUrSh34rm7NVXtLeqMqs/TP8SR41hlGLJItPaKywVszPGAGMrcrBBV1ISNqUjm4rbVj+0se9b6QKjGHe2D6Cpu870eNPuJzZKjdW7MGCVDcwAXSNMvW+THqzlZhmIlxACCEcTUkd9dfz4royPty1ArW4XAIFxyS6Kx6HaPaW+7F/9FdeI2GiztBkNhPn+moPF7/6kKFSHxWQYBkAAagxaChdKl33LUb7KKfAIVITMZWlWXGKRbHWrYy+Lh5LGzbKFBYHphWMjktmbpq3kTHtyZmncHoqpV5myEa1TX2JGRMJWV0x6pOmKCRb9B03z1MGsYgYrM4Mu30j/Wf8BCAGEw3G56sA7yofbLogenIT6XByMUd3Va7w1EaFqwTfSF17tSvcjXfiAld5k7EiOuXh/t7Jv89yTv08Xh1G6zUUTiG/PvzC+9lf+kllYlUylaD0VmyLWykDN9oIcNwAbepmaerfYoCV9d3YbjrVS2JKKrKmTp2njbxs6taL6CU14TOUYewHHZjytKJeNvbFBr56BTSVnylexaCzc0950+F184Oklck2ebxwoV/s5UaGPCIe9F0avuKdg8lQgimnHQNPZazL3sNB9+tDkd39SFDktgmq/vmgwHpCh4/L7XRfdLPpyMQI0hNXU9WEDM+t5cYwkjGxWekPDNQNiU1Su9HNIf8c2CmHSLIVUFi0ry5aVcyt1jh2LCTFFs5mp5JwUvUmlZRhe98PUWGWj+moHIIQAc5IKDXW1PSf3+urfzev8qEjuznANUi6gsURnnENO+wCcyV0WXfjFjDkXuQQMQ23ErFw4SVcoAMC8EI3FyNFXcg48VhRpptXjbexb1MmkStCfPT286A7u4jvcHi9SEoamZ5oIbVW83qoPuL6323gCWG98Nq3lxUopVmNnkLcNSGYXi6SGcRsRWt8mD4Z3xzN1Cxue1MaancoQp64h68eBrcxkZXQwnan29Kvfr70FQ5aCvkFZcsszQHdP8My+ndGDL1fEj8z2xEREb3isFmb9Fk7AHrFcuuLeSTPm0M5jWnwFME1brIZFHyaon2N0HCLRmPTOE1NPbqbGLXsTGgIgBAhAiPd1X3K394qvOhwiK0KziT2Gic1Wn9YDYRQYtgOwKaJM5RNCSDgcfuLxx9xpnmlTirMys3zZuVmZmYGAHwHo42BN56KpqpzUY5QKTqwcwiNyx6XifBod/dpzr72iOyLitTE4G8xXBvQihAhCCUnp7+sb6GgYqD+ROL7D3/bRPD4c8NJ5PQ6g1c6gytBBnLX+hR1zry84f4VbAL26q+/fCxblYE1r/YBZDTqEEAiOUF8QPn4lu/pVX/dJT6yP45Pp7QRAgmBaIH7R17jya/jJcwWeR6oCOjsW2/8JLHoLGyp7jDMDm3qPrBAoy3JN9ZmXXnrpt//1sEOJrJ0/acAz6XTUlZuTvbCi4ryKC88rm5uTlUk9mTRswNRZOupo7xQxaeU3GqPda4yqr1UYjJV1yhTPpqxrqv3qR96QsH4udpcTYrJy9mxD86E3ucZDU0Mf5yudfhLyckBDReztQCOFLshwMuaqnbzKvfh6b2Gpy+VGQAwuHNZ/A0zAk6kab1MlA2EMCCtSQuluIGd2Z3z4//LDzbw4mCXAIlkT71UFpDRfZNIFscu/7Zq/WiQyUiW9RdqqLbipNWuiAMzSILuS6T9QaeeV7dsf/ekPzlNrvj09KCtwrAs+7EUf9IitA1A6e9b8xZfPOX/R7HllnjSPIAicIPAcx/E8Rkgb+5E6ikeqBkMKPansLWGpIznpUyRdxWzk5KTxGFYGZwbnoBJVlmU5EZcT8Zb6mtYDryvVe8sTp+akg9vB4A3GiXJViANXq/iPFv5LzvIv5uXlA1E10Gq9P7V/glk3I9MpyirzbG0No9aKcYJw0ZPviidfz258xyv1iiSOFWXwIsickBUZQoGpiUvvclSsE9LSsehEZuhlfUsGU9ZEAdiqgj6bA6mNiyAIGOODh4+++ur2yLE3XWfe+uxkqJgEwEFfH9T0Ql0UGkMQR7zqL5JzS1XfZDUtCwRXpj8jOyc3d9Lk7KzMnKzMgN+nqtTNqBBddJ69RYptdW1jsjcdU8M57YX5pBBlBQo2Io21FNhotini1nQS06tgjAkAxhxBuLcv1NXZ1ttwWulucHZVOToqXf2NBUrXJCc4HOMmJLNbNAYNJK0z5/xQ6Wecsy7Ozs5BREY6fOpDkfXCs70Fy9R4zrqyWcvOOT2WEwjmE1JCba3i208JLUcdLUddHSdckQjPAeIA8LksPi0Gk0gQdwjStEvIzMth9kp+6gUCB0hVYHisjh7G42KLHiWATVd3Qw0H+jcejweDwf+38dcvPv27lbmxb5RK0wIAZHBayARkFVQCCgGFQFMUnw1zdRGhVgnUxZwtEZTh80+dNq2kdO7U0llTSoqnlJS43S6i0v9TR1SsJBXiTV0ZTsVelaLN2d61a1Mh0YaNDaDV1W3FgFBPb7Clta354z09lQcmx2pnJGpL3JKHUzlQMQKMzs3OMdqTTSmrKQwfOcukedfknXep15/J8YI+zknPutoGuuoRGgmzCTZsFIqVTQ7MejvBsGblCA8NBFIlKRZVepqg/kPUdCSt7WN3Z5UDQKBIRkPkTAabpqmcGPNNiS+5XVi0Xswu4hGAqoBFgLRmJ54oI5aVCdogUVsZRehXTqcTYW7X2+9seXpztOX0xerxBa5gURoUegDw8DUeD4kr9J8JqOuH+j6oi8LZqHC2X0kgwZ9d4C+c6iua5S8o9udOSg9kCYLodrudbo/T6XSIgiiKDocDY0RUQoAAAUJUdrqPFK4jhb2VjcqGZq2gm9Rjd25mACBAKiGSLMcTUmwgFA/3SdFQuLNloLU2Unck3laTrXYXKT1Fbgh4hgZ8Amj23AlVCMsQ5NJbnCW1uUtdZVdOnj7LyWOiyJrx1krd1ezPbD4QDG9falVi0t5DZvUq9VEZGGOEAGEe8wJgXgEkyxJpO01ajottJ4Xeei7cxsXDWIlxcgzJMSTHsRRB8ZgcBym/WJ11JTfvSi5rCheYhDxZMLzcxd8EgFkRTovo0I8pxpjnhd6+vprq6rra6qr3/lL//kvnexPrp0F+AEAFUCymEdJ9IJCQIJSAkARhBUISRGWIILEXvEEuIyRmDgjpYeSNIKfCCb6MjMys7MycvEDepIDfnxnwZfr9vox0DmMaBEiISgw11qzN4GMM4bBJ2ErFWKUPnB68GYQQwojjCIG+ULint6+7q7O/pSbY1iCHur2J3oxoqy/a7Jd6XGokDeIeUNNEMOSATYR4PHhOBFIUquJCfeZCPHe1s7jMmV3kSUvjEBCiGkRiU9AacglMG/lqL4V1ktlUX2M7D7Likt61q187MMaAEMYcwhxgDIAIAFISSIpCIorkKEpEUSICchwRBasSkeJElcHlR+nZXGYx7/GB7r1/QgC2EqGtbJ4agNnI+GHZDoS8++57mzf+V9fZyjU5vVcXSsUeggG4sdRYQeektWAc2iLQNgDtMWiTXa2Kuy0udMYBeFcgKys7b1JmQXGgcEpWdk52dk52To7H60VDyNCaULIx6SNtZmfjGDOVmYcNJgBdaICAqqqylOjt7Q2HQsG+3nBHc6i1rqexOt7TkoP6J0NPAenPT4NcFziECUep6cnJkBjZEeM+QtO7p6/KX7omPycbDW/Jq49kMuDTNIlPw49p1ISNDmzFxmBdeZM1GuvdvAZy1i8rpgnDw8+GNJXkEwIwa4PR3Ays01xDrH10nsGWwHGc6HD09AY/PHjo4IEPQu2N/o6jvu7jBWJiTjrMCQAIAOoYZDzEcDgAEJDjEIxDXxx649CnQq/MBSU8ICPgHdidgT1+zpsFjnTkTEOCC4lOJLiQ4EQOJxaciHcA5gBhjucFQeAFURBFQRAFh5MXRMHh4kWHIPAY48HKx4TWP1aIoqiKrCoKUVVFkYmqEkWS4tFEPC4n4qoiE0VCcpwkokSKQCIG8TBEghDugoEuEgmiaL+gJtI5yYvi6YR4ePA6wOcEJAx3VE4wYvXhDYOfZQjGoRO5+py5A/4ZvTnl/JSK3OllXqcIqqy30Giz3GBSNoDW9FtT5yqbqWoazm0PYysnIhtWlbR28nBFGuzThj8JBjb1+ppaRNmylRpQrSpl64MH6BIlydJAeCASGaivrdn/5vYPd72Uj8PX5EWvLgbRMWj9GqPClvS3qgoKAUUFFUAlQAYXEFAJGvxMBoOPFIJiCoqqOK6imIrpf3EVx4CPIacMHA8qD/LgX0R4IBwiPCI8IhwCHhMnVl1D//GIABAMgBDBQP8DKo9gbCeVfAJwNd3icTgbglNCUSi3zDvv8kDxTFe6j3emCYKALSa6PmLJAE6DupsUHqZ50VZV2sEi3crUem+KXnb50Iv07AplCn7W6zGBANaHUqZoBWVVYqvYWlNzgv4nGGNeEETRUVNXt+uNXW+/8ZoY6ZnvaC8TOme5I2k8eHnwCCBwf7V5bLyc1WcdMZoT2d/qZnhAokJMgRgS+oizCTLrvfPiBWVZZcsnFRamuRxEkYGpE26QeFnosv/UO4psbFdWvjqraErT2ZiiIM0WPzclWKtjwDpFaQIBbMgltIn+Yf1JpkG2BstW6nhGCHEcz/FceCDS2tbe3Fjf2dER6WqJnD06UP2REmyZmU7K08m8LHC4zlH0BHkv/7G3cyM2pGiAAn1R6JKgHmcO+KaikgqcP4cPTErLmZzu9Yg8R1SFzWJn+dagAFuhlwWwgc2skmythESbecXuNPXYp8LGph/sfzuxbiQ2ndBU9dXnD4JZ9gLN/KYf9EZpNnxP6/1pmgFnaAShH3RavfHI/2/vWrrbKLLwrX5ZD1t+CBwSQoAzZ2Y2M8OSX88OFqyYHRuYIQ7jJA4Tv2RbUnerWFgS5ap7v7ott5wA6pPjIyktqSXVV/e7r+9++/V333w1Ojn+8mDyr+7ZP/bp73uUJaLPtjlEM2vplzG9vKaj9PBF9nG192zw+Rd7f/ni6bNn3W7PS5Z6MsiuvfWMcChn4d51nxXWS7oTAD1I4K5pjzMvV6Dn2YWxRlcrQ3KGl1UZy6FZeK9hu/zXaIEp6GjzRG2kkiCpXg+YXA/YJOhosznnJdlOs2wymf7409HR8+fPf/j++Oef0+loWL4ZXr/Yn57szi56ST0s7DCngw51FzVGDx/7eYfg/O0jW5qWNCrp0iYj0xln26NieNl7fLHz6XX3Uf/RJ4Onf9sbfrg/2C7ybFaX5DSiSL2vOLpDQg+tJBPHRoBcMLgxGuKmfoK/rpIzkGuXUsTsVQFfV2Lj663EIrkllXT1ty4+vQ0PM21Mddjbbh2iMQkRmcRUZXUzHt/c3NxcjyaTydX56euj/5z89/tffvj32/89z+vxk759tjV5ms2ebNOTbTroEaUOqu0C1dRC1f7DAdX4PvZ0SucTuhjTWUWnJj8x+6fZsPfxX/uf/bP/0ec7w4+yTi/v9vOtXpFnabqo4ufCOSwtxHqrEpgxT2aDQKDMJiyKDleIVIYFCmMkD9a1w2wLoUSk3WrK9QLYzd96qjpS8N2bMObCzNVAde+y+6LGXWG/cWmOq5sSS9PMJCZJ0rIsX756ffzq9fHL4zdHP568+Onk1bGdXD0qysfZ1RP79nExPiyqw626m1oimxhKiBJD8+CwWfwjSsz62bld7CeLG9ZSbWlGZkamJjOzZjRLz6v0okzPbPc0PzhLds9Nf5rv9A8Otz94vH34Sf/Dp7uDnf3d3cFg285qmpey2NA+hGSPNTiggQ4kRbG99YRpQptGQVu85MRK7RwUawiRNHpCAu9BNHwQ7z5rbCcMQ1l0V1YSYJil02yMmsWtXvkl/AtIEevtzJ2reWGNmdWzi9HVxeXocnR1efb/y9O3V6PLspxQXZlqbKbXdjJKJiMzHiWTcxqfm8mVmV6Z6bUpx8ZWRUKZsVlCqaHc2NTYPLEpzfNGGVFKlBOlhjIia6i0VBGVRBUlpU0qSqr5X1NRUluiJCOT2DRL0sImGWU5pbnJtmxa2M5g1h/a/ge2u2c7O6boFb1+pz/o7OxvbQ86RdHtFJ2trSxN7KLmjO46LKHcKevveWwwGrlZ7a4UZ5ZklsGK1QtxklxqrpRD06CavdGWqk6cQi915SnQkQDtwaEEMdtcLrS2if+7LMlkM/IEBVMBkjUlU/OEhDF2Ni+wXhZI3T67ruuqLKvFUVfVbeNzXd/+KeeTvqqqqqtZXROZolhUgBR5luVFsZUXeZEXWZ6laZZlmdNMYIy5/dWTeT2PiwFj6O6a8yS1wo4r4nTFCCqVcxX/BOywZFeBfyu9u3S1GL3S/k4N5U3Au3uCstJoFTfIF4av1qLIwX4M8F/sbdf71VhpAMtopytre7GwG/jVJWLGblvsCSBjyS4dsLC0vyWU+5IYMitlHA3YYCLtpUBBfkWpIBVWXEW1ygCvBouB5Iki4faHxyBJtjrUilyLJpb3ab3rjoYNcK6YtcPK/w2xKs0cCKPlkmJmIwyHVg7PcwMwa7RdAsujX2Ssh8aGZ4ARBtSXZcKh4BtWPwdEFAw00Mz0kTze6GaNg9Lu9CPiyjxZ8kxtSEOrLDAbzXKXrzSEgY0zhY9LsASpeQxdUGED2BSYaUBOQ5X38fUkhRSS1+0a22gcFThp0VIEUK7gkWQPtCw4WVmF0PZ6ioXSB3SXmSTNG1Kz8MWBHBq7lYQPemFn96toZcqZdryod33ADhPXdgtIrN6DZbNHkm6bxvLjARE4PaiZC8Waaz3Upc1UY429Kh8cCAVlg6EV1SRCo5Zccm7ZEqtQF0Va7tLJGMbRqZqSGiG7UUqPsOiltY5WCQ/XDpOgjaqXUCRZR5pd05Icl+ZuowBGtF+XGs5h1HCcphY43O/Z7Z8lzDhRFPWEARRxmlQfDaK7U1epoQQK6wxToMri1hfqvSRJlQmHCaUxCesdLyr5wwQ136QvQglvFnKA9OoRG27A7AAhSX2ePVlpe5V+rP5k1t2VPEkctWLjqNF0DotVkucS4KiehAd2wK0+jQTAzBpYwCuBwANmRt42GtYpPxCAQwB4OWHNZhadndfUX8VDIbCXG42oRwcRsT9zUzwrA1QaPEdzHjh2Be6G5gJkOzXvCFQH9SZXuWJZao0jjmH2RPNbhMqK4Zbq2t61D/jW2GFWbQfMUmEHNbABYZCUb3qaFLogxcBEts42vH7vx1htZAbIK3ihRC+jKEnnRhG1fDqeqScVVIShGnwaGFYQKjy3ssrD0kAvXCzt140Gx0rD8VjZ6lZs74oA1uxt0REErIqq55PgEhGl2VRS5WhKUDNBW+NKaGLLLAELLTwobGgUhZZuR+XIQcJWmk9PgjYoS5Wp1UOaDSTR4/s4PqxmdZhhauUzrghgb2XjUCFwHQEaQV0riz0ARQ1bxtR6tZDVCgBWngBcX+AAKwFMQukiSNjiFw9BEhXcbmt9R5cuCC6s7PtISl2to/deFpjlJ+yWFp14FC2KUM7y0u8FmpF/uAcL+MB0v5kSejVMUOIvIRnAL/p4FPbSyWx5w0OCdgVIsxfTaAQH/rbbOtqpKwCbDUE1ZrbHWAoGavpONKBtSpXZTQQY4dWT8rGJxBLzxLUcGNjSbU3NIAmNQU2H17wr6DZiT5qLDJ3HdX+u1gDM2kAAY+x7uDUxt6NA6G63oATLMLkX3l3OmNSwAO9llRa4KYtWzjGXVv/y63LDM97r4JHwAJbLY/krSKNYw/xtSHbeB5PbNCi1GqV6mI/WpgVWuhkSnkH4R3KbNfulhq7rSTLg29Fs0wrhKwlamJVJo6Gkl1K60+HeylIDQJI3x+8DwJq4X1MkgxqSsCxGIsxRFaUoKQISYi2uUfCCYWkedqSbRrCjI9RD3+F3SpI3AL4vnkloLonm5ULOzC5rFvBRRsSKLa3mNd0zjqU/jZ1PiUEeyqmxM5PBnrKxtH8uAGMkRyOxJKSXQ0rJ2kwAaX1FpNQD1Pp3KO04ODcDnss29Nu7ky/BRqnH7cbS/vEBHEUyZtqkHtXL4plgewqAzTv8olgWLQXMQGmxHrESaL2euw1u/9QAXtk+UyyLEzVlkhHTGyIQb7u/ydXMK2Vtr1QaAWr9pAjZxsZuANw+tqMY0ASolS5x2KrR1F9tWgqvfOLS18WXHWUretBujg2A12Wloww8XIueeIjGG290MdJbhM/SdO0rER4NR0vvsrKg6ebYAPgh8Kzkrg9c1Uxrq5TWvCzul9gcGwC/X3i+P2Dek29JE71XugwbxP4xjl8B2mOg/LvWPuwAAAAASUVORK5CYII=', 19.60, 5.50, 'admin@example.com', '0.9.13-81');

INSERT INTO `minibar` (`digit`, `label`, `price`, `vat`) VALUES
(1, '', 0.00, 0.00),
(2, '', 0.00, 0.00),
(3, '', 0.00, 0.00),
(4, '', 0.00, 0.00),
(5, '', 0.00, 0.00),
(6, '', 0.00, 0.00),
(7, '', 0.00, 0.00),
(8, '', 0.00, 0.00),
(9, '', 0.00, 0.00),
(0, '', 0.00, 0.00);
