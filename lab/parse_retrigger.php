<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/19/14
 * Time: 9:40 PM
 */

echo '<pre>';

$localPathPrefix = dirname(__FILE__).'/';
$triggerLocation = $localPathPrefix.'parse_trigger.php';

$commandString = 'nohup php '.$triggerLocation;
$reTriggerCommandString = 'nohup php '.__FILE__;
$commandSuffix = ' > /dev/null &';




shell_exec($commandString.$commandSuffix);




if(file_get_contents($localPathPrefix.'fetch_loop.txt') === '1'){


    usleep(250 * 1000);




    shell_exec($reTriggerCommandString.$commandSuffix);


    // date_default_timezone_set('CET');
    file_put_contents($localPathPrefix.'last_fetch_loop.txt', date('Y-m-d H:i:s', time()));


    // echo ++$i.PHP_EOL;



}