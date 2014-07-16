
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});



Parse.Cloud.job("bgTest", function(request, status) {

    // Set up to modify user data
    Parse.Cloud.useMasterKey();

});

Parse.Cloud.define('pullTzevaAdom', function(request, response){

    Parse.Cloud.useMasterKey();

    Parse.Cloud.httpRequest({
        method: 'GET',
        // url: 'http://www.galaxy-battle.de/node/server/tzevaadom.json',
        url: 'http://tzevaadom.com/alert.json',
        // url: 'http://www.galaxy-battle.de/node/server/tsevaadom_3.json',
        body: {
            title: 'Vote for Pedro',
            body: 'If you vote for Pedro, your wildest dreams will come true'
        },

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

                        for(var i = 0; i < coordinates.length; i++){

                            var currentLocation = coordinates[i];
                            if(currentLocation.length < 7){ // x.x;x.x -> 7 characters
                                continue;
                            }

                            var locationComponents = currentLocation.split(';');
                            var latitude = parseFloat(locationComponents[0]);
                            var longitude = parseFloat(locationComponents[1]);
                            var geoPoint = new Parse.GeoPoint({'latitude': latitude, 'longitude': longitude});

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