<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 8:49 PM
 */

error_reporting(E_ALL);
echo '<pre>';




$curl = curl_init('http://irondomeapp.co.il/lab/parse_trigger.php');
// $curl = curl_init('http://www.klh-dev.com/adom/alert/alerts.json');

// curl_setopt($curl, CURLOPT_HEADER, true); // get response header
// curl_setopt($curl, CURLOPT_VERBOSE, true); // no idea what that means

curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
// curl_setopt($curl, CURLOPT_ENCODING, '');
$externalAlertResponse = curl_exec($curl);
curl_close($curl);


echo $externalAlertResponse;