<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 8:49 PM
 */

error_reporting(E_ALL);




$localPathPrefix = dirname(__FILE__).'/';
echo $localPathPrefix;



$triggerCount = file_get_contents($localPathPrefix.'cron_count.txt');
file_put_contents($localPathPrefix.'cron_count.txt', ++$triggerCount);




