<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 4:14 PM
 */


die();

$convenientLookup = [];

$rawLookupData = file_get_contents('pikud_areas.csv');
$lookupRows = explode(PHP_EOL, $rawLookupData);

foreach($lookupRows as $currentRow){

    if(++$i == 10){

        // break;

    }

    $rowParts = explode(',', $currentRow);

    $cityName = $rowParts[0];
    $areaCode = $rowParts[1];

    $googleLookupRaw = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($cityName));
    $googleLookupData = json_decode($googleLookupRaw, true);
    $filteredGoogleLookup = $googleLookupData['results'][0];



    $convenientLookup[$areaCode][$cityName] = $filteredGoogleLookup;

}

echo '<pre>';

file_put_contents('areas.json', json_encode($convenientLookup, JSON_PRETTY_PRINT));

print_r($convenientLookup);