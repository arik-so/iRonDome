<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/19/14
 * Time: 9:40 PM
 */

echo '<pre>';
set_time_limit(0); // we want this thing to run forever

$localPathPrefix = dirname(__FILE__).'/';
$triggerLocation = $localPathPrefix.'parse_external.php';

$commandString = 'nohup php '.$triggerLocation;
$commandSuffix = ' > /dev/null &';


if($_GET['debug'] == 1){

    $response = shell_exec($commandString.' debug nocurl '.$commandSuffix);
    echo $response;

    die();

}


$i = 0;

while(file_get_contents($localPathPrefix.'fetch_loop.txt') === '1'){

    shell_exec($commandString.$commandSuffix);


    // date_default_timezone_set('CET');
    file_put_contents($localPathPrefix.'last_fetch_loop.txt', date('Y-m-d H:i:s', time()));


    // echo ++$i.PHP_EOL;

    usleep(250 * 1000);

}