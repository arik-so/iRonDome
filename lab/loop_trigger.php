<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/29/14
 * Time: 12:54 AM
 */



echo '<pre>';
error_reporting(E_ALL);

$localPathPrefix = dirname(__FILE__).'/';
$triggerLocation = $localPathPrefix.'fetch_loop.php';

$commandString = 'nohup php '.$triggerLocation;
$commandSuffix = ' > /dev/null &';

$response = exec($commandString.$commandSuffix);
echo $response;

die();