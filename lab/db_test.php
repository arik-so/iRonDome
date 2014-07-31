<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/31/14
 * Time: 10:57 AM
 */



mysql_connect('127.0.0.1', 'irda', 'iRonDome18');
mysql_select_db('alerts');

// this place is proper
mysql_query('INSERT INTO `alerts` SET `json` = "this", `response` = "that" ');