//
//  IRDAppDelegate.m
//  iRonDome
//
//  Created by Arik Sosman on 7/16/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDAppDelegate.h"
#import "iRonDome-Swift.h"

#import <MagicalRecord/MagicalRecord.h>


#import "Flurry.h"
#import "FlurryAds.h"



#define kParseApplicationId @"KFQeWT9x9MoHlUvBUlEDj77Rh3zZ8piQIMzQ2Anf"
#define kParseClientKey @"ibx6T6Bvmuxa5gTaY3zSzLajDPpumblyybno3orz"
#define kFlurryAPIKey @"VR6WNDMCRNHG5KJ48QQW"

@interface IRDAppDelegate()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL isInBackground;

@end

@implementation IRDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    

    
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {

        }
    }
    
    
    
    [Flurry startSession:kFlurryAPIKey];
    [FlurryAds initialize:self.window.rootViewController];
    
    
    
    // let's start monitoring location, right?
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = 100; // we want it updated for a one hundred meter distance filter
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // this is not super precise, but sufficient for our purpose
    self.locationManager.activityType = CLActivityTypeOther;
    self.locationManager.pausesLocationUpdatesAutomatically = NO; // we want it to constantly keep the user updated. IT IS IMPORTANT!
    self.locationManager.delegate = self;
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    
    
    
    
    
    
    
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"IRDModel"];
    
    
    
    
    return YES;
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    //vibrate
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newRocket" object:nil];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        // [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    
    
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
       //  [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}





- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    /*
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
     
    */
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"PNS Error: %@ \n because \n %@", error.localizedDescription, error.localizedFailureReason);
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *latestLocation = locations[0];
    
    /* 
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    geoPoint.latitude = latestLocation.coordinate.latitude;
    geoPoint.longitude = latestLocation.coordinate.longitude;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:geoPoint forKey:@"lastKnownLocation"];
    
    if(self.isInBackground){
        
        [currentInstallation save];
        
    }else{
        
        [currentInstallation saveInBackground];
        
    }
    
    */
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newRocket" object:nil]; // whenever the app opens, we ned to check for new rockets
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"newRocket" object:nil]; // whenever the app opens, we ned to check for new rockets
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // [MagicalRecord cleanUp];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}









@end
