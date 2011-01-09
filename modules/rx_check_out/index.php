<?php
  /* vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
  Codificación: UTF-8
  +----------------------------------------------------------------------+
  | Elastix version 2.0.0-22                                               |
  | http://www.elastix.org                                               |
  +----------------------------------------------------------------------+
  | Copyright (c) 2006 Palosanto Solutions S. A.                         |
  +----------------------------------------------------------------------+
  | Cdla. Nueva Kennedy Calle E 222 y 9na. Este                          |
  | Telfs. 2283-268, 2294-440, 2284-356                                  |
  | Guayaquil - Ecuador                                                  |
  | http://www.palosanto.com                                             |
  +----------------------------------------------------------------------+
  | The contents of this file are subject to the General Public License  |
  | (GPL) Version 2 (the "License"); you may not use this file except in |
  | compliance with the License. You may obtain a copy of the License at |
  | http://www.opensource.org/licenses/gpl-license.php                   |
  |                                                                      |
  | Software distributed under the License is distributed on an "AS IS"  |
  | basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See  |
  | the License for the specific language governing rights and           |
  | limitations under the License.                                       |
  +----------------------------------------------------------------------+
  | The Original Code is: Elastix Open Source.                           |
  | The Initial Developer of the Original Code is PaloSanto Solutions    |
  +----------------------------------------------------------------------+
  $Id: index.php,v 1.1 2010-05-08 11:05:33 Franck Danard franckd@agmp.org Exp $ */

include_once "libs/paloSantoGrid.class.php";
include_once "libs/paloSantoForm.class.php";

function _moduleContent(&$smarty, $module_name)
{
    //include module files
    include_once "modules/$module_name/configs/default.conf.php";
    include_once "modules/$module_name/libs/paloSantoCheckOut.class.php";

    //include file language agree to elastix configuration
    //if file language not exists, then include language by default (en)
    $lang=get_language();
    $base_dir=dirname($_SERVER['SCRIPT_FILENAME']);
    $lang_file="modules/$module_name/lang/$lang.lang";
    if (file_exists("$base_dir/$lang_file")) include_once "$lang_file";
    else include_once "modules/$module_name/lang/en.lang";

    //global variables
    global $arrConf;
    global $arrConfModule;
    global $arrLang;
    global $arrLangModule;
    $arrConf = array_merge($arrConf,$arrConfModule);
    $arrLang = array_merge($arrLang,$arrLangModule);

    //folder path for custom templates
    $templates_dir=(isset($arrConf['templates_dir']))?$arrConf['templates_dir']:'themes';
    $local_templates_dir="$base_dir/modules/$module_name/".$templates_dir.'/'.$arrConf['theme'];

    //conexion resource
    $pDB = new paloDB($arrConf['dsn_conn_database']);
    $pDB_Ast = new paloDB("mysql://root:eLaStIx.2oo7@localhost/asterisk");
    $pDB_CDR = new paloDB("mysql://root:eLaStIx.2oo7@localhost/asteriskcdrdb");
    $pDB_Set = new paloDB("sqlite3:///$arrConf[elastix_dbdir]/settings.db");
    $pDB_Rat = new paloDB("sqlite3:///$arrConf[elastix_dbdir]/rate.db");

    //actions
    $action = getAction();
    $content = "";

    switch($action){
        case "save_new":
            $content = saveNewCheckOut($smarty, $module_name, $local_templates_dir, $pDB, $pDB_Ast, $pDB_CDR, $pDB_Set, $pDB_Rat, $arrConf, $arrLang);
            break;
        default: // view_form
            $content = viewFormCheckOut($smarty, $module_name, $local_templates_dir, $pDB, $pDB_Ast, $pDB_CDR, $pDB_Set, $pDB_Rat, $arrConf, $arrLang);
            break;
    }
    return $content;
}

function viewFormCheckOut($smarty, $module_name, $local_templates_dir, &$pDB, &$pDB_Ast, &$pDB_CDR, &$pDB_Set, &$pDB_Rat, $arrConf, $arrLang)
{
    $pCheckOut = new paloSantoCheckOut($pDB);
    $arrFormCheckOut = createFieldForm($arrLang, $pDB);
    $oForm = new paloForm($smarty,$arrFormCheckOut);

    //begin, Form data persistence to errors and other events.
    $_DATA  = $_POST;
    $action = getParameter("action");
    $id     = getParameter("id");
    $smarty->assign("ID", $id); //persistence id with input hidden in tpl

    if($action=="view")
        $oForm->setViewMode();
    else if($action=="view_edit" || getParameter("save_edit"))
        $oForm->setEditMode();
    //end, Form data persistence to errors and other events.

    if($action=="view" || $action=="view_edit"){ // the action is to view or view_edit.
        $dataCheckOut = $pCheckOut->getCheckOutById($id);
        if(is_array($dataCheckOut) & count($dataCheckOut)>0)
            $_DATA = $dataCheckOut;
        else{
            $smarty->assign("mb_title", $arrLang["Error get Data"]);
            $smarty->assign("mb_message", $pCheckOut->errMsg);
        }
    }

    $smarty->assign("SAVE", $arrLang["Save"]);
    $smarty->assign("EDIT", $arrLang["Edit"]);
    $smarty->assign("CANCEL", $arrLang["Cancel"]);
    $smarty->assign("REQUIRED_FIELD", $arrLang["Required field"]);
    $smarty->assign("IMG", "images/list.png");

    $htmlForm = $oForm->fetchForm("$local_templates_dir/form.tpl",$arrLang["CheckOut"], $_DATA);
    $content = "<form  method='POST' style='margin-bottom:0;' action='?menu=$module_name'>".$htmlForm."</form>";

    return $content;
}

function TimeCall($second)
{
	$temp = $second % 3600;
	$time[0] = ( $second - $temp ) / 3600 ;
	$time[2] = $temp % 60 ;
	$time[1] = ( $temp - $time[2] ) / 60;

	$result = $time[0].":".$time[1].":".$time[2];
       return $result;
}

function saveNewCheckOut($smarty, $module_name, $local_templates_dir, &$pDB, &$pDB_Ast, &$pDB_CDR, &$pDB_Set, &$pDB_Rat, $arrConf, $arrLang)
{
    include "modules/$module_name/libs/billing_lib.php";
    $pCur    = new paloSantoCheckOut($pDB_Set);
    $pSQLite = new paloSantoCheckOut($pDB_Rat);
    $curr    = $pCur->loadCurrency();
    $arrRate = $pSQLite->loadRates();

    $pCheckOut = new paloSantoCheckOut($pDB);
    $pCheckOut_Ast = new paloSantoCheckOut($pDB_Ast);
    $pCheckOut_CDR = new paloSantoCheckOut($pDB_CDR);

    $arrFormCheckOut = createFieldForm($arrLang, $pDB);
    $oForm = new paloForm($smarty,$arrFormCheckOut);
    $_DATA = $_POST;

    if(!$oForm->validateForm($_POST)){
        // Validation basic, not empty and VALIDATION_TYPE 
        $smarty->assign("mb_title", $arrLang["Validation Error"]);
        $arrErrores = $oForm->arrErroresValidacion;
        $strErrorMsg = "<b>{$arrLang['The following fields contain errors']}:</b><br/>";
        if(is_array($arrErrores) && count($arrErrores) > 0){
            foreach($arrErrores as $k=>$v)
                $strErrorMsg .= "$k, ";
        }
        $smarty->assign("mb_message", $strErrorMsg);
        $content = viewFormCheckOut($smarty, $module_name, $local_templates_dir, $pDB, $pDB_Ast, $pDB_CDR, $pDB_Set, $pDB_Rat, $arrConf, $arrLang);
    }
    else{
        $pRoom = new paloSantoCheckOut($pDB); // <------------- inutile  $pRoom = $pCheckOut !!!
        $where = "where id = '".$_DATA['room']."'";
        $arrRoom = $pRoom->getCheckOut('rooms', $where);
        $arrExt = $arrRoom['0'];
	 
        // Capturer les donn�es du minibar pour la facturation! 

        // Update room : The room was busy and now it's free and not clean.
        //---------------------------------------------
        $value['free'] = '1';
        $value['clean'] = '0';
        $value['minibar'] = '';
        $where = "id = '".$_DATA['room']."'";
        $arrUpdateRoom = $pRoom->updateQuery('rooms', $value, $where);

        // Lock the extension after checkout or not.
        //---------------------------------------------
        $arrConfig = $pRoom->getCheckOut('config', '');
        $arrLock = $arrConfig['0'];

        $cmd = "/usr/sbin/asterisk -rx 'database put LOCKED ".$arrExt['extension']." 0'";
	 if ( $arrLock['locked'] == "1")
        	$cmd = "/usr/sbin/asterisk -rx 'database put LOCKED ".$arrExt['extension']." ".$arrLock['locked']."'";
        exec($cmd);

        // Put a date of checkout
        //---------------------------------------------
        $value_re['date_co'] = "'".date('Y-m-d H:i:s')."'";
        $where = "room_id = '".$arrExt['id']."' and status = '1'";
        $arrUpdateRoom = $pRoom->updateQuery('register', $value_re, $where);

        // Delete the account code extension into Freepbx data
        //---------------------------------------------
        $value_rl['value']  = "'true'";
        $where              = "variable = 'need_reload';";
        $arrReload          = $pCheckOut_Ast->updateQuery('admin',$value_rl, $where);

        $value_ac['data']   = "''";
        $where              = "id = '".$arrExt['extension']."' and keyword = 'accountcode';";
        $arrAccount         = $pCheckOut_Ast->updateQuery('sip',$value_ac, $where);

        $cmd="/var/lib/asterisk/bin/module_admin reload";
        exec($cmd);

        // Find any room calls
        //---------------------------------------------
        
	 $where 	  = "where room_id = '".$_DATA['room']."' and status = '0'";
        $arrConf_Guest = $pCheckOut->getCheckOut('register', $where);
        $arrGuest      = $arrConf_Guest['0'];

	 $where         = "WHERE src = '".$arrExt['extension']."' and billsec > '0' and calldate > '".$arrGuest['date_ci']."'".
 			    " and calldate < '".$arrGuest['date_co']."' and disposition = 'ANSWERED' and accountcode ='".$arrGuest['guest_id']."'".
			    " and dcontext = 'from-internal' and dst <> '100'";

        $arrCDR = $pCheckOut_CDR->getCDR($where);
        $i=0;
	 $total_bill=0;
        $billing_rate = 0.01;

	 foreach($arrCDR as $key => $value){
	 	$calldate[$key] = $value['calldate'];
              $dst[$key]	  = $value['dst'];
		$billsec[$key]  = TimeCall($value['billsec']);
		$total_bill	  = $total_bill + ($value['billsec'] * $billing_rate);
              $i++;		
	 }

        $strMsg = "Checkout Done";

        // Write the billing into the html file. 
        //---------------------------------------------
        $arrConf   = $pCheckOut->getCheckOut('config', '');
        $Config    = $arrConf['0'];

	 $Billing_page = Billing_Header();
        $Bnumber=$arrGuest['id'].date('Ymd');
	 $title = "Billing  at ".date('D j M Y')." Number : ".$Bnumber;
	 $Billing_page = $Billing_page."".Title($title);

        $where = "where id = '".$arrGuest['guest_id']."'";
        $arrFor = $pCheckOut->getCheckOut('guest', $where);
        $For = $arrFor[0];
	 $for= $For['first_name']." ".$For['last_name']."<br>\n".$For['address']."<br>\n".$For['cp']." ".$For['city'];
        $Billing_page = $Billing_page.Header_company($Config['company'],"<img src='".$Config['logo64']."'>",$for);

        $Billing_page = $Billing_page."".Sale_title("Sale");

	 // How many nights ?
        $arrNight = $pCheckOut->getNightNumber($arrGuest['date_ci'], $arrGuest['date_co'], $arrGuest['id']);
	 foreach($arrNight as $key => $value)
	 	$Night = $value;
        if( $Night == '0')
	 	$Night = "1";  // A night should be calculated, even if there's no night. 
				 // The room could be took in the day and be free in the same day. 

	 // Line with the number of Nights
	 //----------------------------------

        $where = "where room_model = '".$arrExt['model']."'";
        $arrModel = $pCheckOut->getCheckOut('models', $where);
	 $Model = $arrModel[0];
        $puht   = strval($Model['room_price']);
        $patc  = ($puht*$Night)*(1+(strval($Model['room_vat'])/100));
	 $vat   = $patc - ($puht*$Night) ;
        $Billing_page = $Billing_page."".Sale("Nights with room ".$Model['room_model'], $Night, $puht, $vat, $patc, $curr);

	 // There's a mini-bar?
	 //------------------------------------

	 if (isset($arrExt['mini_bar']))
	 {
		$Billing_page = $Billing_page.Sale("<b>Nini Bar :</b>", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		$minibar=str_replace(" ","",$arrExt['mini_bar']);
		foreach(count_chars($minibar,1) as $val_min => $QT)
		{
		        $where = "where digit = '".chr($val_min)."'";
        		 $arrMiniBar = $pCheckOut->getCheckOut('minibar', $where);
			 $MiniBar    = $arrMiniBar[0];
			 $Billing_page = $Billing_page.Sale($MiniBar['label'], $QT, $MiniBar['price'], "1", strval($QT)*strval($MiniBar['price']), $curr);		 
		}	
	 }

	// The client has made some call? 
       //--------------------------------

	 if ($i > 0)
	 	$Billing_page = $Billing_page.Sale("There is some calls", $i, "&nbsp;", "&nbsp;", "&nbsp;", $curr);
        $Billing_page = $Billing_page."</tbody></table><br>";

	// We want some details ?
	//------------------------

	 if($_DATA['details'] == 'on'){
        	$key=0;
		$Billing_page = $Billing_page.Detail_table_Title();
	 	foreach($arrCDR as $key => $value)
			$Billing_page = $Billing_page.Detail_table_Line($value['calldate']." - ".$value['dst'], TimeCall($value['billsec']), $value['billsec'], "&nbsp;", ($value['billsec'] * $billing_rate), $curr);
	 }
	 $Billing_page = $Billing_page."</tbody></table><br>";
	 $Billing_page = $Billing_page.Total_Billing($ht, $vat, $total, $curr);

        $name	     = $Bnumber.".html";
	 $name_path = "/var/www/html/roomx_billing/".$name;

	 $Billing_file = fopen($name_path, 'w+');
	 fwrite($Billing_file,$Billing_page);
	 fclose($Billing_file);

	 if($_DATA['sending_by_mail'] == 'on' && isset($For['mail']) ){
     	 	$headers = "From: ".$For['mail']."\n"
     			   ."Reply-To: ".$congif['mail']."\n"
     		  	   ."Content-Type: text/html; charset='iso-8859-1\n"
     			   ."Content-Transfer-Encoding: 8bit";

	 	$Billing_file = fopen($name_path, 'r');
		$contents = fread($Billing_file, filesize($name_path));
		fclose($Billing_file);
		$message = $contents;

     		if(mail($For['mail'], 'Your Billing', $message, $headers))
     		{
          		$strMsg .= " and mail sent.";
     		}
     		else
     		{
          		$strMsg .= " and <b>mail error!!!</b>";
     		} 

	
	 }

        // Put the register with the status O.
        //---------------------------------------------
        $value_re['status'] 	= "'0'";
        $value_re['billing_file']  = "'".$name."'";
        $where 			= "room_id = '".$arrExt['id']."' and status = '1'";
        $arrUpdateRoom 		= $pRoom->updateQuery('register', $value_re, $where);

        $smarty->assign("mb_message", $strMsg);
        $smarty->assign("call_number", $i);
        $smarty->assign("total", $total_bill);
        $smarty->assign("bil", "1");
	 $smarty->assign("bil_link", $name);

        $htmlForm = $oForm->fetchForm("$local_templates_dir/form.tpl",$arrLang["CheckOut"], $_DATA);
        $content = viewFormCheckOut($smarty, $module_name, $local_templates_dir, $pDB, $pDB_Ast, $pDB_CDR, $pDB_Set, $pDB_Rat, $arrConf, $arrLang);        

    }
    return $content;
}

function createFieldForm($arrLang, &$pDB)
{
    $pRoom= new paloSantoCheckOut($pDB);
    $where = "where free = '0'";
    $arrRoom=$pRoom->getCheckOut('rooms', $where);
    $arrGroup=$pRoom->getGroupCheckOut();
     
    foreach($arrRoom as $kR => $valueR)
    	$arrOptionsR[$valueR['id']] = $valueR['room_name'];

    if (!isset($valueR['room_name']))
    	$arrOptionsR = array( '1' => 'No Room!' );

    $arrOptionsG = array( '0' => 'No Group' );
    foreach($arrGroup as $kG => $valueG){
       $kG++;
    	$arrOptionsG[$kG] = $valueG['groupe'];
	}

    $arrFields = array(
            "room"   => array(      "LABEL"                  => $arrLang["Room"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "SELECT",
                                            "INPUT_EXTRA_PARAM"      => $arrOptionsR,
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => "",
                                            "EDITABLE"               => "si",
                                            ),
            "group"   => array(      "LABEL"                  => $arrLang["Group"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "SELECT",
                                            "INPUT_EXTRA_PARAM"      => $arrOptionsG,
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => "",
                                            "EDITABLE"               => "si",
                                            ),
            "billing"   => array(      "LABEL"                  => $arrLang["Billing"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "CHECKBOX",
                                            "INPUT_EXTRA_PARAM"      => "",
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => ""
                                            ),
            "details"   => array(      "LABEL"                  => $arrLang["Details"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "CHECKBOX",
                                            "INPUT_EXTRA_PARAM"      => "",
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => ""
                                            ),
            "sending_by_mail"   => array(   "LABEL"                  => $arrLang["Sending by mail"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "CHECKBOX",
                                            "INPUT_EXTRA_PARAM"      => "",
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => ""
                                            ),
            "printing_the_billing" => array("LABEL"                  => $arrLang["Printing the billing"],
                                            "REQUIRED"               => "no",
                                            "INPUT_TYPE"             => "CHECKBOX",
                                            "INPUT_EXTRA_PARAM"      => "",
                                            "VALIDATION_TYPE"        => "text",
                                            "VALIDATION_EXTRA_PARAM" => ""
                                            ),

            );
    return $arrFields;
}

function getAction()
{
    if(getParameter("save_new")) //Get parameter by POST (submit)
        return "save_new";
    else if(getParameter("save_edit"))
        return "save_edit";
    else if(getParameter("delete")) 
        return "delete";
    else if(getParameter("new_open")) 
        return "view_form";
    else if(getParameter("action")=="view")      //Get parameter by GET (command pattern, links)
        return "view_form";
    else if(getParameter("action")=="view_edit")
        return "view_form";
    else
        return "report"; //cancel
}
?>