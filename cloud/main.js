
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success(request);
});



Parse.Cloud.job("bgTest", function(request, status) {

    // Set up to modify user data
    Parse.Cloud.useMasterKey();

});

Parse.Cloud.define('pushFromHFC', function(request, response){

    Parse.Cloud.useMasterKey();

    var alertID = parseInt(request['params']['alertID']);
    var data = request['params']['data'];


    var isDuplicateAlert = false;


    var Siren = Parse.Object.extend('Siren');

    // first, let's check whether there are any entries with the current alertID
    var duplicateAlarmQuery = new Parse.Query(Siren);
    duplicateAlarmQuery.equalTo('alertID', alertID);
    duplicateAlarmQuery.count({

        success: function(count){

              if(count > 0){

                  response.error('Duplicate alert id: '+alertID);

              }

              if(count < 0){

                  response.error('Could not check duplicates?!');

              }

              if(count == 0){


                  // only add this new stuff if the count is zero


                  // first, let's check whether this alert ID has already been processed
                  if(isDuplicateAlert){ return; } // we already know this shit

                  var affectedDeviceIDs = [];
                  var cityNameString = '';


                  var iClosure = 0;
                  var iClosureMaximum = data.length;

                  console.log('Max necessary closure call count: '+iClosureMaximum);

                  for(var i = 0; i < data.length; i++){

                      var currentCity = data[i];
                      var currentCityName = currentCity['name'];

                      cityNameString += currentCityName+', ';

                      if(!currentCity['bounds']){

                          iClosureMaximum--;
                          continue;

                      }

                      var edgeNE = new Parse.GeoPoint(parseFloat(currentCity['bounds']['northeast']['lat']), parseFloat(currentCity['bounds']['northeast']['lng']));
                      var edgeSW = new Parse.GeoPoint(parseFloat(currentCity['bounds']['southwest']['lat']), parseFloat(currentCity['bounds']['southwest']['lng']));
                      var center = new Parse.GeoPoint(parseFloat(currentCity['center']['lat']), parseFloat(currentCity['center']['lng']));


                      var currentSiren = new Siren();
                      currentSiren.set('edgeNE', edgeNE);
                      currentSiren.set('edgeSW', edgeSW);
                      currentSiren.set('center', center);
                      currentSiren.set('toponym', currentCityName);
                      currentSiren.set('alertID', alertID);
                      currentSiren.save();







                      console.log('Current Bounds: '+JSON.stringify(edgeNE)+'; '+JSON.stringify(edgeSW));
                      // console.log(edgeNE);
                      // console.log(edgeSW);

                      var currentDeviceQuery = new Parse.Query(Parse.Installation); // let's create a Parse installation query
                      currentDeviceQuery.withinGeoBox('lastKnownLocation', edgeSW, edgeNE);

                      currentDeviceQuery.find({

                          success: function(results){

                              for(var j = 0; j < results.length; j++){

                                  var currentDevice = results[j];
                                  affectedDeviceIDs.push(currentDevice.id);

                              }

                              console.log('Found geo-relevant devices');

                          }, error:function(error){

                              console.log('Could not find the geo-relevant devices because: '+JSON.stringify(error));
                              response.error('Could not find devices within last known location.');

                          }

                      }).then(function(){

                          iClosure++; // we need to check the stuff in here

                          console.log('Current closure count: '+iClosure);


                          if(iClosure == iClosureMaximum){ // we have reached the end of this loop


                              console.log('Affected devuces: '+JSON.stringify(affectedDeviceIDs));


                              cityNameString = cityNameString.substr(0, cityNameString.length-2);

                              if(cityNameString.length > 140){
                                  cityNameString = cityNameString.substr(0, 140)+'…';
                              }


                              // debugging so I always also get a push notification
                              // affectedDeviceIDs.push('iXfNcrybPd'); // Arik's iPhone
                              // affectedDeviceIDs.push('O7XytkyAfE'); // Arik's iPad




                              // we have found all the necessary device IDs

                              var urgentPushNotificationQuery = new Parse.Query(Parse.Installation);
                              urgentPushNotificationQuery.containedIn('objectId', affectedDeviceIDs);



                              var informativePushNotificationQuery = new Parse.Query(Parse.Installation);
                              informativePushNotificationQuery.notContainedIn('objectId', affectedDeviceIDs);





                              Parse.Push.send({
                                  where: urgentPushNotificationQuery,
                                  data: {
                                      alert: 'TAKE COVER!',
                                      sound: 'major_alert.caf',
                                      badge: 'Increment'
                                  }
                              }, {
                                  success: function(){

                                      // response.success('Push sent!');

                                  },
                                  error: function(error){

                                      console.error('Could not send push notification');
                                      response.error('Could not send urgent push notification.');
                                      // response.error(error);

                                  }
                              }).then(function(){






                                  // only after the emergency alarms have been sent need we also send the ones about whether or not to take cover

                                  Parse.Push.send({
                                      where: informativePushNotificationQuery,
                                      data: {
                                          alert: 'Sirens in: '+cityNameString,
                                          sound: 'minor_alert_alarm.m4a',
                                          badge: 'Increment'
                                      }
                                  }, {
                                      success: function(){

                                          // response.success('Push sent!');

                                      },
                                      error: function(error){

                                          console.error('Could not send push notification');
                                          response.error('Could not send non-urgent push notification.');
                                          // response.error(error);

                                      }
                                  }).then(function(){



                                      response.success('everything is done');



                                  });









                              });







                              // response.success(affectedDeviceIDs);

                          }

                      });

                  }






              }

        }

    });


});









Parse.Cloud.define('pullTzevaAdom', function(request, response){

    Parse.Cloud.useMasterKey();

    Parse.Cloud.httpRequest({
        method: 'GET',
        // url: 'http://www.galaxy-battle.de/node/server/tzevaadom.json',
        // url: 'http://tzevaadom.com/alert.json',
        url: 'http://www.galaxy-battle.de/node/server/tsevaadom_3.json',
        /*body: {
            title: 'Vote for Pedro',
            body: 'If you vote for Pedro, your wildest dreams will come true'
        },*/

        success: function(httpResponse) {

            var incomingRockets = JSON.parse(httpResponse.text);
            var coordinates = incomingRockets['Coords'];
            var alertID = parseInt(incomingRockets['ID']);

            var Rocket = Parse.Object.extend('Rocket');

            // first, let's check whether there are any entries with the current alertID
            var query = new Parse.Query(Rocket);
            query.equalTo('alertID', alertID);
            query.count({

                success: function(number){

                    if(number > 0){ // we already know about these rockets

                        response.error('Alert already registered');

                    }else{

                        // ok, we don't know anything about this alert yet, so let's notify our users

                        var processed = 0;




                        // let's initiate the emergency query





                        for(var i = 0; i < coordinates.length; i++){

                            var currentLocation = coordinates[i];
                            if(currentLocation.length < 7){ // x.x;x.x -> 7 characters
                                continue;
                            }

                            var locationComponents = currentLocation.split(';');
                            var latitude = parseFloat(locationComponents[0]);
                            var longitude = parseFloat(locationComponents[1]);
                            var geoPoint = new Parse.GeoPoint({'latitude': latitude, 'longitude': longitude});



                            var pushDistanceQuery = new Parse.Query(Parse.Installation);
                            pushDistanceQuery.withinKilometers('lastKnownLocation', geoPoint, 6000);

                            Parse.Push.send({
                                where: pushDistanceQuery,
                                data: {
                                    alert: 'Red Alarm!'
                                }
                            }, {
                                success: function(){

                                },
                                error: function(error){

                                    console.error('Could not send push notification');

                                }
                            });


                            // response.success(geoPoint);
                            // return;

                            var currentRocket = new Rocket();


                            currentRocket.set('location', geoPoint);
                            currentRocket.set('alertID', alertID);
                            currentRocket.save(null, {

                                success: function(){

                                },

                                error: function(rocket, error){

                                    console.error('Could not save: '+error);

                                }

                            });

                            processed++;

                        }




                        // response.success('Registered '+processed+'/'+coordinates.length+' new rockets. Stay safe! '+JSON.stringify(incomingRockets));

                    }
                },

                error: function(error){

                    response.error(error);

                }

            });

        },

        error: function(error) {

            console.error('Request failed with response code ' + httpResponse.status);
            response.error(error);

        }

    });

    // response.success()

});