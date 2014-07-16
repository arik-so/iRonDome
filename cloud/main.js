
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
        url: 'http://www.galaxy-battle.de/node/server/tzevaadom.json',
        // url: 'http://tzevaadom.com/alert.json',
        body: {
            title: 'Vote for Pedro',
            body: 'If you vote for Pedro, your wildest dreams will come true'
        },
        success: function(httpResponse) {
            console.log(httpResponse.text);
            // response.success('here wer are');
            response.success(httpResponse.text);
            return;
        },
        error: function(httpResponse) {
            console.error('Request failed with response code ' + httpResponse.status);
            response.error(httpResponse);
            return;
        }
    });

    // response.success()

});