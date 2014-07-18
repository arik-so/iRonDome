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

    foreach($localities as $currentName => $googleDetails){

        if($googleDetails){

            continue;

        }

        echo $code.' -> '.$currentName.PHP_EOL;

        /* $googleLookupRaw = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($currentName));
        $googleLookupData = json_decode($googleLookupRaw, true);
        $filteredGoogleLookup = $googleLookupData['results'][0];

        $convenientLookup[$code][$currentName] = $filteredGoogleLookup;

        file_put_contents('areas.json', json_encode($convenientLookup, JSON_PRETTY_PRINT)); */

        // die();

    }

}


// print_r($convenientLookup);