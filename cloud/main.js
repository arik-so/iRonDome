
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});



Parse.Cloud.job("bgTest", function(request, status) {

    // Set up to modify user data
    Parse.Cloud.useMasterKey();

});