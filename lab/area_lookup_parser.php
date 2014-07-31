<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 4:14 PM
 */

$convenientLookup = [];

$rawLookupData = file_get_contents('pikud_areas.csv');
$lookupRows = explode(PHP_EOL, $rawLookupData);

foreach($lookupRows as $currentRow){

    if(++$i == 2){

        // break;

    }

    $rowParts = explode(',', $currentRow);

    $cityName = $rowParts[0];
    $areaCode = $rowParts[1];

    $url = 'http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($cityName).'&components=country:IL';
    echo $url.PHP_EOL;
    $googleLookupRaw = file_get_contents($url);
    $googleLookupData = json_decode($googleLookupRaw, true);

    $googleResults = $googleLookupData['results'];
    $filteredGoogleLookup = $googleResults[0];
    // $filteredGoogleLookup = $googleLookupData['results'];

    if(count($googleResults) != 1){
        $filteredGoogleLookup = 'ambiguous_results';
    }


    $convenientLookup[$areaCode][$cityName] = $filteredGoogleLookup;

}

echo '<pre>';

print_r($convenientLookup);

// die();

file_put_contents('areas.json', json_encode($convenientLookup, JSON_PRETTY_PRINT));

