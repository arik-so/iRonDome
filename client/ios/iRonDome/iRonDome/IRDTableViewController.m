//
//  IRDTableViewController.m
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDTableViewController.h"
#import "Reachability.h"
#import "iRonDome-Swift.h"

#import <MagicalRecord/MagicalRecord.h>

#define kRocketTimeThreshold -60*2  //  * 60 * 24 * 5 // two minutes
#define kMapZoomLatitude 400000
#define kMapZoomLongitude 400000
#define kAvenirLight @"Avenir-Light"
#define kAvenirBook @"Avenir-Book"

#define kDownloadEndpoint @"http://ec2-52-8-181-240.us-west-1.compute.amazonaws.com/iRon-Dome-Server/web/app_dev.php/alarms"

#define MAP_PADDING 2 // we want it a bit higher in here
#define MINIMUM_VISIBLE_LATITUDE 0.01

@interface IRDTableViewController ()

// @property (nonatomic, strong) NSMutableArray *currentRockets;
// @property (nonatomic, strong) NSMutableArray *pastRockets;

@property (nonatomic, strong) NSMutableArray *currentAlertIDs;
@property (nonatomic, strong) NSMutableArray *pastAlertIDs;

@property (strong, nonatomic) NSMutableDictionary *sirensByAlertID;
@property NSTimeInterval olderSirenTime;

@property (strong, nonatomic) NSManagedObjectID *pendingSegueAlertID;

@property (strong, nonatomic) CustomTableViewCell *customCell;

@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIActivityIndicatorView *downloadIndicator;

@end

@implementation IRDTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupMap];
    
    [self prepareRocketData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(downloadRocketData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"newRocket" object:nil];
    
    
    self.downloadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadRocketData)];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //dynamic cell height for table view in iOS8
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 160.0;
    
    //create network session
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
}

- (void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:@"newRocket"]) {
        [self prepareRocketData];
        [self downloadRocketData];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareRocketData{
    
    // self.currentRockets = @[].mutableCopy;
    // self.pastRockets = @[].mutableCopy;
    
    self.currentAlertIDs = @[].mutableCopy;
    self.pastAlertIDs = @[].mutableCopy;
    
    self.sirensByAlertID = @{}.mutableCopy;
    
    
    NSMutableArray *currentSirens = @[].mutableCopy;
    
    

    
    
    // let's fetch the necessary stuff
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSTimeInterval rightNow = [NSDate date].timeIntervalSince1970;
    NSTimeInterval threshold = rightNow + kRocketTimeThreshold;
    
    __block BOOL incomingRockets = NO; 
    
    
    NSArray *allSirens = [Siren MR_findAllSortedBy:@"alertID" ascending:NO];
    for(Siren *currentSiren in allSirens){
        
        if(currentSiren.timestamp.timeIntervalSince1970 < threshold){
            
            [self.pastAlertIDs addObject:currentSiren.objectID];
            
        }else{
            
            [self.currentAlertIDs addObject:currentSiren.objectID];
            [currentSirens addObject:currentSiren];
            
            NSTimeInterval timeDelta =  currentSiren.timestamp.timeIntervalSince1970 - threshold;
            [NSTimer scheduledTimerWithTimeInterval:timeDelta target:self selector:@selector(refreshLocalSirens) userInfo:nil repeats:NO];
            
            incomingRockets = YES;
            
            
            
            for(Area *currentArea in currentSiren.areas){
            
            
                CLLocationCoordinate2D  ctrpoint;
                ctrpoint.latitude = currentArea.centerLatitude.doubleValue;
                ctrpoint.longitude = currentArea.centerLongitude.doubleValue;
                IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
                [rocketAnnotation initWithCoordinate:ctrpoint userTitle:NSLocalizedString(@"siren", nil) userSubtitle:[NSString stringWithFormat:@"%f;%f", currentArea.centerLatitude.doubleValue, currentArea.centerLongitude.doubleValue]];
                rocketAnnotation.rocketId = currentSiren.alertID.stringValue;
                
                [self.mapView addAnnotation:rocketAnnotation];
                
            }
            
        }
        
    }
    
    Siren *lastSiren = allSirens.lastObject;
    self.olderSirenTime = lastSiren.timestamp.timeIntervalSince1970;
    
    
    
    if(incomingRockets){
        
        MKCoordinateRegion rocketBounds = [IRDImpactCalculator determineImpactBoundsForSirens:currentSirens];
        MKCoordinateRegion region = rocketBounds;
        // region.center.latitude = (latitudeSouth + latitudeNorth) / 2;
        // region.center.longitude = (longitudeWest + longitudeEast) / 2;
        
        region.span.latitudeDelta *= MAP_PADDING;
        region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE) ? MINIMUM_VISIBLE_LATITUDE : region.span.latitudeDelta;
        region.span.longitudeDelta *= MAP_PADDING;
        
        MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
        [self.mapView setRegion:scaledRegion animated:YES];
        
        
    }
    
    
}

- (void)refreshLocalSirens{
    
    [self prepareRocketData];
    [self.tableView reloadData];
    
}

- (void)testTableView{
    [self.tableView reloadData];
}

- (void)setupMap{
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 31.0000;
    zoomLocation.longitude= 35.0000;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, kMapZoomLatitude, kMapZoomLongitude);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)downloadRocketData{
    
    //make sure array is null and then init it for refresh
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.downloadIndicator];
    [self.downloadIndicator startAnimating];
    
    /*
    
    NSString *dbTable = [SCLocalSiren getDatabaseTable];
    NSString *query = [NSString stringWithFormat:@"SELECT alertID FROM %@ ORDER BY alertID DESC LIMIT 0,1", dbTable];
    
    __block NSNumber *alertID = nil;
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query];
        
        if([result next]){
            
            alertID = result.resultDictionary[@"alertID"];
            
        }
        
    }];
     
    */
    
    //TODO: New logic for downloading rocket data without parse
    [self downloadWithCompletion:^(BOOL finished) {
        
    }];
    
    
    /*PFQuery *newSirenQuery = [PFQuery queryWithClassName:@"Siren"];
    [newSirenQuery orderByDescending:@"alertID"];
    [newSirenQuery setLimit:1000];
    
    if(alertID && [alertID isKindOfClass:[NSNumber class]]){
    
        [newSirenQuery whereKey:@"alertID" greaterThan:alertID];
        
    }
    
    //get current rockets
    [newSirenQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu rockets.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                
                SCLocalSiren *duplicate = [SCLocalSiren fetchByServerID:object.objectId];
                if(duplicate){
                    continue; // we don't wanna add a rocket we already have locally
                }
                
                SCLocalSiren *siren = [SCLocalSiren create];
                [siren initFromServerResponse:object];
                
                // [siren remove];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self prepareRocketData];
                
                [self.refreshControl endRefreshing];
                self.navigationItem.rightBarButtonItem = self.refreshButton;
                
                [self.tableView reloadData];
                
            });
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            [self.refreshControl endRefreshing];
            
        }

    }];*/
}

#pragma mark - Download Data
- (void)downloadWithCompletion:(void (^)(BOOL))completion{
    
    
    
    if ([self networkAvailable]) {
        
        NSString *downloadEndpoint = kDownloadEndpoint;
        
        Siren *firstSiren = [Siren MR_findFirstOrderedByAttribute:@"alertID" ascending:NO];
        if(firstSiren){
            downloadEndpoint = [downloadEndpoint stringByAppendingPathComponent:firstSiren.alertID.stringValue];
        }
        
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSURL *url = [NSURL URLWithString:downloadEndpoint];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setTimeoutInterval:30.0f];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (!error) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                if (httpResp.statusCode == 200) {
                    
                    NSError *jsonError;
                    
                    //TODO: write json data to database
                    
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&jsonError];
                    NSLog(@"%@", jsonDict);
                    
                
                    if (!jsonError) {
                        
                        NSArray *sirens = jsonDict[@"response"][@"sirens"];
                        NSDictionary *areas = jsonDict[@"response"][@"areas"];                        
                        
                        // let's save this stuff in a background thread
                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                            
                            // first of all, let's walk through the areas and see whether they are already known to us, shall we?
                            for(NSString *areaID in areas){
                                
                                NSDictionary *currentAreaDetails = areas[areaID];
                                
                                Area *currentArea = [Area MR_findFirstByAttribute:@"areaID" withValue:areaID inContext:localContext];
                                if(currentArea){ continue; }
                                
                                currentArea = [Area MR_createEntityInContext:localContext];
                                
                                currentArea.areaID = currentAreaDetails[@"area_id"];
                                currentArea.toponymShort = currentAreaDetails[@"toponym_short"];
                                currentArea.toponymLong = currentAreaDetails[@"toponym_long"];
                                currentArea.centerLatitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"center_latitude"]];
                                currentArea.centerLongitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"center_longitude"]];
                                currentArea.northEdgeLatitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"north_edge_latitude"]];
                                currentArea.southEdgeLatitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"south_edge_latitude"]];
                                currentArea.westEdgeLongitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"west_edge_longitude"]];
                                currentArea.eastEdgeLongitude = [[NSDecimalNumber alloc] initWithString:currentAreaDetails[@"east_edge_longitude"]];
                                
                                
                            }
                            
                            
                            for(NSDictionary *currentSirenDetails in sirens){
                                
                                NSString *alertIDString = currentSirenDetails[@"alert_id"];
                                NSString *timestampString = currentSirenDetails[@"timestamp"];
                                
                                long long alertID = alertIDString.longLongValue;
                                NSTimeInterval timestamp = timestampString.longLongValue;
                                
                                
                                Siren *currentSiren = [Siren MR_findFirstByAttribute:@"alertID" withValue:@(alertID) inContext:localContext];
                                if(currentSiren){ continue; }
                                
                                currentSiren = [Siren MR_createEntityInContext:localContext];
                                
                                currentSiren.alertID = @(alertID);
                                currentSiren.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
                                
                                NSArray *affectedAreaIDs = currentSirenDetails[@"area_ids"];
                                if(!affectedAreaIDs){ continue; }
                                
                                NSMutableSet *areaSet = [NSMutableSet setWithSet:currentSiren.areas];
                                for(NSString *areaID in affectedAreaIDs){
                                    
                                    Area *currentAffectedArea = [Area MR_findFirstByAttribute:@"areaID" withValue:areaID inContext:localContext];
                                    if(!currentAffectedArea){ continue; }
                                    
                                    [areaSet addObject:currentAffectedArea];
                                    
                                }
                                
                                [currentSiren setAreas:areaSet];
                                
                            }
                            
                            
                            
                            
                            
                            
                        } completion:^(BOOL contextDidSave, NSError *error) {
                            
                            NSNumber *sirenCount = [Siren MR_numberOfEntities];
                            NSNumber *areaCount = [Area MR_numberOfEntities];
                            
                            NSLog(@"here");
                            
                            
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            [self prepareRocketData];
                            
                            [self.refreshControl endRefreshing];
                            self.navigationItem.rightBarButtonItem = self.refreshButton;
                            
                            [self.tableView reloadData];
                            
                            
                        }];
                        
                        
                        
                        
                        
                        /*
                        
                        NSArray *contentsOfRootDirectory = jsonDict[@"response"][@"sirens"];
                        
                        for (NSDictionary *data in contentsOfRootDirectory) {
                            if (data[@"alert_id"]) {
                                [self.currentAlertIDs addObject:data[@"alert_id"]];
                            }
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            [self prepareRocketData];
                            
                            [self.refreshControl endRefreshing];
                            self.navigationItem.rightBarButtonItem = self.refreshButton;
                            
                            [self.tableView reloadData];

                        });
                         
                        */
                        
                    }
                }
                else{
                    NSLog(@"unexpected response %@",[NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES);
                });
            }
        }];
        
        [dataTask resume];
    }
    else{
        //TODO: no internet so read just load the local database
        
    }
}

#pragma mark - Reachability
- (BOOL)networkAvailable{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if ([[self stringFromStatus:status] isEqualToString:@"Not Reachable"]) {
        return NO;
    }
    return YES;
}

//Reachability convert network status to string
- (NSString *)stringFromStatus:(NetworkStatus) status {
    
    NSString *string;
    switch(status) {
        case NotReachable:
            string = @"Not Reachable";
            break;
        case ReachableViaWiFi:
            string = @"Reachable via WiFi";
            break;
        case ReachableViaWWAN:
            string = @"Reachable via WWAN";
            break;
        default:
            string = @"Unknown";
            break;
    }
    return string;
}


#pragma mark - Date Creator
- (NSDate *)todaysDate{
    NSDate *currentDate = [NSDate date];
    NSDate *dateTwoMinutesEarlier = [currentDate dateByAddingTimeInterval:kRocketTimeThreshold];
    NSString *dateString = [dateTwoMinutesEarlier description];
    NSLog(@"%@", dateString);
    return dateTwoMinutesEarlier;
}

- (NSString *)formatDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone localTimeZone];
    
    formatter.doesRelativeDateFormatting = YES;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSString *newTime = [formatter stringFromDate:date];
    return newTime;
}

#pragma mark - Map View

//annotation and map delegate functions. Controls pin colors callout text etc
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    // CustomAnnotationView *pinView = (CustomAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!pinView){
        // pinView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        pinView.animatesDrop = YES;
        
        //        UIImageView *customPinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotationIcon.png"]];
        //        [customPinView setFrame:CGRectMake(0, 0, 32, 32)];
        //        customPinView.backgroundColor = [UIColor clearColor];
        //        customPinView.layer.borderWidth = 0.5;
        //        customPinView.layer.borderColor = [UIColor blackColor].CGColor;
        //        customPinView.layer.cornerRadius = customPinView.image.size.width / 8;//makes prof pic circle
        //        customPinView.layer.masksToBounds = YES;
        
        //TODO: decide if we want users to touch info button
        //pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        //pinView.leftCalloutAccessoryView = customPinView;
        pinView.canShowCallout = YES;
        // pinView.calloutOffset = CGPointMake(10, 25);
        // pinView.centerOffset = CGPointMake(-5, -5);
    }
    else{
        pinView.annotation = annotation;
    }
    
    return pinView;
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control{
    NSLog(@"calloutAccessoryControlTapped:");
    // NSString *annotationID = ((IRDMapAnnotation *) [view annotation]).rocketId;
    //[self performSelector:@selector(showInfo:) withObject:annotationID];
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    
    // add the animation here
    CGRect visibleRect = [_mapView annotationVisibleRect];
    
    for(MKAnnotationView *view in views){
        if([view isKindOfClass:[CustomAnnotationView class]]){
            CGRect endFrame = view.frame;
            CGRect startFrame = endFrame;
            
            startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
            view.frame = startFrame;
            
            [UIView animateWithDuration:0.4 animations:^{
                view.frame = endFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0){
        return self.currentAlertIDs.count;
    }else if(section == 1){
        return self.pastAlertIDs.count;
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
  
    //clear background color
    cell.backgroundColor = [UIColor clearColor];
    // Configure the cell...
    NSArray *rocketArray = @[];
    
    if(indexPath.section == 0){
        rocketArray = self.currentAlertIDs.copy;
    }else if(indexPath.section == 1){
        rocketArray = self.pastAlertIDs.copy;
    }
    
    // NSNumber *currentAlertID = rocketArray[indexPath.row];
    NSManagedObjectID *currentAlertID = rocketArray[indexPath.row];
    Siren *siren = (Siren *)([[NSManagedObjectContext MR_defaultContext] existingObjectWithID:currentAlertID error:nil]);
    
    // Siren *siren = self.sirensByAlertID[currentAlertID];
    
    NSString *placeLabels = @"";
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    NSDate *sirenTime = siren.timestamp;
    
    for(Area *currentSiren in siren.areas.allObjects){
        
        placeLabels = [NSString stringWithFormat:@"%@, %@", placeLabels, currentSiren.toponymLong];
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.northEdgeLatitude.doubleValue;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.northEdgeLatitude.doubleValue);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.southEdgeLatitude.doubleValue;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.southEdgeLatitude.doubleValue);
        }
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.eastEdgeLongitude.doubleValue;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.eastEdgeLongitude.doubleValue);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.westEdgeLongitude.doubleValue;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.westEdgeLongitude.doubleValue);
        }
        
    }
    
    if(placeLabels.length >= 2){
        placeLabels = [placeLabels substringFromIndex:2];
    }
    
//    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
//    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    
//    subtitleLabel.text = placeLabels;
//    subtitleLabel.numberOfLines = 0;
//    
//    titleLabel.text = [self formatDate:sirenTime];

    cell.timeLabel.text = [self formatDate:sirenTime];
    cell.sirenLabel.text = placeLabels;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSArray *rocketArray = @[];
    
    if(section == 0){
        rocketArray = self.currentAlertIDs.copy;
    }else if(section == 1){
        rocketArray = self.pastAlertIDs.copy;
    }
    
    UIView *headerView = [[UIView alloc] init];
    
    headerView.frame = CGRectMake(0, 0, 320, 20);
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1.0];
    UILabel *currentRocketsLabel = [[UILabel alloc] init];
    currentRocketsLabel.frame = CGRectMake(20, 10, 320, 21);
    currentRocketsLabel.font = [UIFont fontWithName:kAvenirBook size:16];
    currentRocketsLabel.textAlignment = NSTextAlignmentLeft;
    currentRocketsLabel.textColor = [UIColor blackColor];
    [headerView addSubview:currentRocketsLabel];
    
    if (section == 0) {
        
        NSString *currentRocketsText = NSLocalizedString(@"current_rockets", nil);
        currentRocketsText = [currentRocketsText stringByReplacingOccurrencesOfString:@"{count}" withString:@(rocketArray.count).stringValue];
        
        currentRocketsLabel.text = currentRocketsText;
    }
    if (section == 1) {
        
        NSDate *oldestSirenDate = [NSDate dateWithTimeIntervalSince1970:self.olderSirenTime];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.timeZone = [NSTimeZone localTimeZone];
        
        // formatter.doesRelativeDateFormatting = YES;
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        
        NSString *newTime = [formatter stringFromDate:oldestSirenDate];
        
        NSString *pastRocketsText = NSLocalizedString(@"past_rockets", nil);
        pastRocketsText = [pastRocketsText stringByReplacingOccurrencesOfString:@"{count}" withString:@(rocketArray.count).stringValue];
        pastRocketsText = [pastRocketsText stringByReplacingOccurrencesOfString:@"{since}" withString:newTime];
        
        
        if (rocketArray.count < 1) {
            
            currentRocketsLabel.text = NSLocalizedString(@"no_past_rockets", nil);
            
        }else{
            
            currentRocketsLabel.text = pastRocketsText;
            
        }
        
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *rocketArray = @[];
    
    if(indexPath.section == 0){
        rocketArray = self.currentAlertIDs.copy;
    }else if(indexPath.section == 1){
        rocketArray = self.pastAlertIDs.copy;
    }

    NSManagedObjectID *currentAlertID = rocketArray[indexPath.row];
    
    // NSNumber *currentAlertID = rocketArray[indexPath.row];
    self.pendingSegueAlertID = currentAlertID;
    
    [self performSegueWithIdentifier:@"showRocketSegue" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showRocketSegue"]){
        
        NSManagedObjectID *currentAlertID = self.pendingSegueAlertID;
        self.pendingSegueAlertID = nil;
        
        IRDSingleRocketTableViewController *destVC = segue.destinationViewController;
        destVC.alertID = currentAlertID;
        
    }
}


@end
