<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 4:40 PM
 */


$convenientLookup = json_decode(file_get_contents('areas.json'), true);

echo '<pre>';

$convenientLookupCopy = $convenientLookup;

foreach($convenientLookupCopy as $code => $localities){

    foreach($localities as $cityName => $googleDetails){

        if($googleDetails !== 'ambiguous_results'){

            continue;

        }

        echo $code.' -> '.$cityName.PHP_EOL;




        $url = 'http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($cityName).'&components=country:IL';
        // echo $url.PHP_EOL;
        $googleLookupRaw = file_get_contents($url);
        $googleLookupData = json_decode($googleLookupRaw, true);

        $googleResults = $googleLookupData['results'];
        $filteredGoogleLookup = $googleResults[0];
        // $filteredGoogleLookup = $googleLookupData['results'];

        if(count($googleResults) < 1){
            $filteredGoogleLookup = 'ambiguous_results';

            echo count($googleResults).': '.$url.PHP_EOL.PHP_EOL;

        }

        // print_r($googleResults);

        $convenientLookup[$code][$cityName] = $filteredGoogleLookup;

        file_put_contents('areas.json', json_encode($convenientLookup, JSON_PRETTY_PRINT));




        /* $googleLookupRaw = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($currentName));
        $googleLookupData = json_decode($googleLookupRaw, true);
        $filteredGoogleLookup = $googleLookupData['results'][0];

        $convenientLookup[$code][$currentName] = $filteredGoogleLookup;

        file_put_contents('areas.json', json_encode($convenientLookup, JSON_PRETTY_PRINT)); */

        // die();

    }

}


// print_r($convenientLookup);