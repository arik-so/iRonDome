<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 8:49 PM
 */

error_reporting(E_ALL);
echo 'here';




$localPathPrefix = dirname(__FILE__).'/';



$triggerCount = file_get_contents($localPathPrefix.'trigger_count.txt');
file_put_contents($localPathPrefix.'trigger_count.txt', ++$triggerCount);




$doDebug = $_GET['debug'] || in_array('debug', $argv);
$noCurl = $_GET['nocurl'] || in_array('nocurl', $argv);



$recodedResponse = '{
"id" : "1405974086170",
"title" : "פיקוד העורף התרעה במרחב ",
"data" : [
"אשקלון 238, עוטף עזה 238",
"31"
]
}
';

$recodedResponse = '{ "id" : "1406642190975", "title" : "פיקוד העורף התרעה במרחב ", "data" : [ "217" ] }';








if(!$noCurl){

    $curl = curl_init('http://www.oref.org.il/WarningMessages/alerts.json');
    // $curl = curl_init('http://www.klh-dev.com/adom/alert/alerts.json');

    // curl_setopt($curl, CURLOPT_HEADER, true); // get response header
    // curl_setopt($curl, CURLOPT_VERBOSE, true); // no idea what that means

    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    // curl_setopt($curl, CURLOPT_ENCODING, '');
    $externalAlertResponse = curl_exec($curl);
    curl_close($curl);


    $recodedResponse = mb_convert_encoding($externalAlertResponse, 'utf-8', 'utf-16');

}





echo '<pre>';
// echo $recodedResponse;

// echo 'here';






$processedExternalAlert = json_decode($recodedResponse, true);




print_r($processedExternalAlert);




$convenientLookup = json_decode(file_get_contents($localPathPrefix.'areas.json'), true); // these are the lookup codes for the affected codes we have found




$affectedCodesRaw = $processedExternalAlert['data'];
if(empty($affectedCodesRaw)){ die(); } // there's nothing to do here



$affectedCodes = array();
$affectedCities = array();
$affectedBounds = array();

$simplifiedCities = array();

$usedCenters = array();



foreach($affectedCodesRaw as $currentCodeRaw){

    $codeParts = explode(',', $currentCodeRaw);

    foreach($codeParts as $currentPartialCodeRaw){

        $currentCode = preg_replace('/[^0-9]/', null, $currentPartialCodeRaw);

        if(empty($currentCode)){ continue; } // this code is weird
        if(in_array($currentCode, $affectedCodes)){ continue; } // we already know this code

        // $affectedCodes[] = $currentCode;
        array_push($affectedCodes, $currentCode);

        $currentLookup = $convenientLookup[$currentCode];
        $affectedCities[$currentCode] = $currentLookup;

        if(!$currentLookup){
            continue;
        }


        // let's process the citiy names
        foreach($currentLookup as $codeName => $geoData){

            $relevantAddressComponent = $geoData['address_components'][0];
            $geometry = $geoData['geometry'];

            $currentBounds = $geometry['bounds'];
            if(!empty($currentBounds)){
                // $affectedBounds[] = $currentBounds;
                array_push($affectedBounds, $currentBounds);
            }else{
                continue; // continuing if bounds empty
            }

            if($relevantAddressComponent['types'][0] !== 'locality'){
                continue; // we don't want bus stations and shit
            }

            $center = $geometry['location'];

            if(in_array($center, $usedCenters)){ continue; }
            array_push($usedCenters, $center);

            $currentCityDetails = array();
            $currentCityDetails['name'] = str_replace(', Israel', null, $relevantAddressComponent['long_name']); // some names end with ', Israel', and we don't want that
            $currentCityDetails['bounds'] = $currentBounds;
            $currentCityDetails['center'] = $center;

            // $simplifiedCities[] = $currentCityDetails;
            array_push($simplifiedCities, $currentCityDetails);

            // print_r($relevantAddressComponent);

        }


    }



    // print_r($currentLookup);

}

if(empty($affectedCodes)){ die(); } // nothing relevant }


/*
if($doDebug){


    $simplifiedCities[] = [
        'name' => 'Hameln',
        'bounds' => [
            'northeast' => [
                'lat' => 55.000001,
                'lng' => 15.0000001
            ],
            'southwest' => [
                'lat' => 44.00000009,
                'lng' => 4.000000009
            ]
        ],
        'center' => [
            'lat' => 52.1082726,
            'lng' => 9.362171
        ]
    ];




    $simplifiedCities[] = [
        'name' => 'Klein Berkel',
        'bounds' => [
            'northeast' => [
                'lat' => 52.0932024,
                'lng' => 9.3612585
            ],
            'southwest' => [
                'lat' => 52.0695399,
                'lng' => 9.327022999999999
            ]
        ],
        'center' => [
            'lat' => 52.089444,
            'lng' => 9.350555999999999
        ]
    ];



}
*/







print_r($affectedCodes);

// print_r($cityNames);
// print_r($affectedBounds);
print_r($simplifiedCities);




$parseOutput = array();
$parseOutput['alertID'] = $processedExternalAlert['id'];
$parseOutput['data'] = $simplifiedCities;





$parsePushAlert = json_encode($parseOutput);

echo $parsePushAlert;

// if($noCurl){ die(); }


define('APPLICATION_ID', 'KFQeWT9x9MoHlUvBUlEDj77Rh3zZ8piQIMzQ2Anf');
define('API_KEY', 'o5MGYiye3pau4Gj3ogyr4l7o3BGtYtEP3RO0Ltu3');

$curl = curl_init('https://api.parse.com/1/functions/pushFromHFC');

curl_setopt($curl, CURLOPT_PORT, 443);
curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);

curl_setopt($curl, CURLOPT_HTTPHEADER, array(
    'X-Parse-Application-Id: '.APPLICATION_ID,
    'X-Parse-REST-API-Key: '.API_KEY,
    'Content-Type: application/json'
));

// curl_setopt($curl, CURLOPT_HEADER, true); // get response header
// curl_setopt($curl, CURLOPT_VERBOSE, true); // no idea what that means
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);

curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, $parsePushAlert);

$responseJSON = curl_exec($curl);
curl_close($curl);

echo '<pre>';
$response = json_decode($responseJSON, true);
print_r($response);


// we need to keep track of what's happening because of these fucking duplicate alerts, goddammit!

mysql_connect('127.0.0.1', 'irda', 'iRonDome18');
mysql_set_charset('utf8'); // very important to set the utf8 charset

mysql_select_db('alerts');

// this place is proper
mysql_query('INSERT INTO `alerts` SET `alertID` = "'.mysql_real_escape_string($processedExternalAlert['id']).'", `oref` = "'.mysql_real_escape_string($recodedResponse).'", `json` = "'.mysql_real_escape_string($parsePushAlert).'", `response` = "'.mysql_real_escape_string($responseJSON).'" ');



