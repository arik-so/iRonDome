//
//  IRDTableViewController.m
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDTableViewController.h"
#define kRocketTimeThreshold -60*2 // two minutes
#define kMapZoomLatitude 400000
#define kMapZoomLongitude 400000
#define kAvenirLight @"Avenir-Light"
#define kAvenirBook @"Avenir-Book"

@interface IRDTableViewController ()

// @property (nonatomic, strong) NSMutableArray *currentRockets;
// @property (nonatomic, strong) NSMutableArray *pastRockets;

@property (nonatomic, strong) NSMutableArray *currentAlertIDs;
@property (nonatomic, strong) NSMutableArray *pastAlertIDs;

@property (strong, nonatomic) NSMutableDictionary *sirensByAlertID;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self prepareRocketData];
    
    //download rocket data
    [self downloadRocketData];
    
    [self setupMap];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(downloadRocketData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

}

- (void)prepareRocketData{
    
    // self.currentRockets = @[].mutableCopy;
    // self.pastRockets = @[].mutableCopy;
    
    self.currentAlertIDs = @[].mutableCopy;
    self.pastAlertIDs = @[].mutableCopy;
    
    self.sirensByAlertID = @{}.mutableCopy;
    
    
    // let's fetch the necessary stuff
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSTimeInterval rightNow = [NSDate date].timeIntervalSince1970;
    NSTimeInterval threshold = rightNow + kRocketTimeThreshold;
    
    
    NSString *dbTable = [SCLocalSiren getDatabaseTable];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY alertID DESC, timestamp DESC, toponym ASC", dbTable];
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query];
        
        while([result next]){
            
            SCLocalSiren *currentSiren = [[SCLocalSiren alloc] init];
            [currentSiren initWithFetchResponse:result.resultDictionary];
            
            NSNumber *alertIDObject = @(currentSiren.alertID);
            
            if(!self.sirensByAlertID[alertIDObject]){
                self.sirensByAlertID[alertIDObject] = @[].mutableCopy;
                
                
                
                
                
                if(currentSiren.timestamp < threshold){
                    
                    // [self.pastRockets addObject:currentSiren];
                    [self.pastAlertIDs addObject:alertIDObject];
                    
                }else{
                    
                    // [self.currentRockets addObject:currentSiren];
                    [self.currentAlertIDs addObject:alertIDObject];
                    
                    
                    // when will the current siren reach the threshold?
                    NSTimeInterval timeDelta =  currentSiren.timestamp - threshold;
                    
                    [NSTimer scheduledTimerWithTimeInterval:timeDelta target:self selector:@selector(refreshLocalSirens) userInfo:nil repeats:NO];
                    
                    /* [self.currentAlertIDs addObject:@(currentRocket.alertID)];
                    
                    [self.currentRockets addObject:currentRocket];
                    
                    CLLocationCoordinate2D  ctrpoint;
                    ctrpoint.latitude = currentRocket.latitude;
                    ctrpoint.longitude = currentRocket.longitude;
                    IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
                    [rocketAnnotation initWithCoordinate:ctrpoint userTitle:@"Rocket" userSubtitle:[NSString stringWithFormat:@"%f;%f", currentRocket.latitude, currentRocket.longitude]];
                    rocketAnnotation.rocketId = currentRocket.serverID;
                    
                    [self.mapView addAnnotation:rocketAnnotation]; */
                    
                }
                
            }
            
            if(currentSiren.timestamp >= threshold){
                
                CLLocationCoordinate2D  ctrpoint;
                ctrpoint.latitude = currentSiren.latitude;
                ctrpoint.longitude = currentSiren.longitude;
                IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
                [rocketAnnotation initWithCoordinate:ctrpoint userTitle:@"Rocket" userSubtitle:[NSString stringWithFormat:@"%f;%f", currentSiren.latitude, currentSiren.longitude]];
                rocketAnnotation.rocketId = currentSiren.serverID;
                
                [self.mapView addAnnotation:rocketAnnotation];
                
            }
        
            [self.sirensByAlertID[alertIDObject] addObject:currentSiren];
            
        }
        
    }];
    
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
    
    NSString *dbTable = [SCLocalSiren getDatabaseTable];
    NSString *query = [NSString stringWithFormat:@"SELECT alertID FROM %@ ORDER BY alertID DESC LIMIT 0,1", dbTable];
    
    __block NSNumber *alertID = nil;
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query];
        
        if([result next]){
            
            alertID = result.resultDictionary[@"alertID"];
            
        }
        
    }];
    
    PFQuery *newSirenQuery = [PFQuery queryWithClassName:@"Siren"];
    
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
                
                
                /* CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:rocket.latitude longitude:rocket.longitude];
                [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    
                    if(!placemarks){ return; }
                    
                    CLPlacemark *firstPlacemark = placemarks[0];
                    if(!firstPlacemark){ return; }
                    
                    rocket.toponym = firstPlacemark.name;
                    [rocket saveAttribute:@"toponym"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                        
                    });
                    
                }]; */
                
                
                /* PFGeoPoint *location = object[@"location"];
                NSLog(@"Object Id: %@ Latitude: %f Longitude: %f", object.objectId, location.latitude, location.longitude);
                [self.currentRockets addObject:[NSArray arrayWithObjects:object.objectId, [NSNumber numberWithDouble:location.latitude], [NSNumber numberWithDouble:location.longitude], nil]];
                //add pins to map
                CLLocationCoordinate2D  ctrpoint;
                ctrpoint.latitude = location.latitude;
                ctrpoint.longitude = location.longitude;
                IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
                [rocketAnnotation initWithCoordinate:ctrpoint userTitle:@"Rocket" userSubtitle:[NSString stringWithFormat:@"%f;%f", location.latitude, location.longitude]];
                rocketAnnotation.rocketId = object.objectId;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView performSelector:@selector(addAnnotation:) withObject:rocketAnnotation afterDelay:0.2];
                }); */
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self prepareRocketData];
                
                [self.refreshControl endRefreshing];
                
                [self.tableView reloadData];
                
            });
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            [self.refreshControl endRefreshing];
            
        }
        
    }];
    
    
    
}

#pragma mark - Date Creator
- (NSDate *)todaysDate{
    NSDate *currentDate = [NSDate date];
    NSDate *dateTwoMinutesEarlier = [currentDate dateByAddingTimeInterval:kRocketTimeThreshold];
    NSString *dateString = [dateTwoMinutesEarlier description];
    NSLog(@"%@", dateString);
    return dateTwoMinutesEarlier;
}

#pragma mark - Map View

//annotation and map delegate functions. Controls pin colors callout text etc
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    CustomAnnotationView *pinView = (CustomAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!pinView){
        pinView = [[CustomAnnotationView alloc]
                   initWithAnnotation:annotation
                   reuseIdentifier:annotationIdentifier];
        
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
        pinView.calloutOffset = CGPointMake(10, 25);
        pinView.centerOffset = CGPointMake(-5, -5);
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *rocketArray = @[];
    
    if(indexPath.section == 0){
        rocketArray = self.currentAlertIDs.copy;
    }else if(indexPath.section == 1){
        rocketArray = self.pastAlertIDs.copy;
    }
    
    NSNumber *currentAlertID = rocketArray[indexPath.row];
    
    NSArray *currentSirens = self.sirensByAlertID[currentAlertID];
    
    NSString *placeLabels = @"";
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    NSDate *sirenTime = nil;
    
    for(SCLocalSiren *currentSiren in currentSirens){
        
        placeLabels = [NSString stringWithFormat:@"%@, %@", placeLabels, currentSiren.toponym];
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.latitudeNorth;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.latitudeNorth);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.latitudeSouth;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.latitudeSouth);
        }
        
        
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.longitudeEast;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.longitudeEast);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.longitudeWest;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.longitudeWest);
        }
        
        if(!sirenTime){
            sirenTime = [NSDate dateWithTimeIntervalSince1970:currentSiren.timestamp];
        }
        
        
    }
    
    placeLabels = [placeLabels substringFromIndex:2];
    
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    
    titleLabel.text = placeLabels;
    
    
    // [rocket reload]; // the data might have been modified, so we should reload it just in case
    
    // Configure the cell...
    /* UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    if (rocketArray.count == 0) {
        //dont set the text yet
    }
    else{
        
        if(rocket.toponym){
            
            titleLabel.text = rocket.toponym;
            titleLabel.adjustsFontSizeToFitWidth = YES;
            
        }
        
        subtitleLabel.text = [NSString stringWithFormat:@"%f, %f", rocket.latitude, rocket.longitude];
        
    } */
    
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
        if(rocketArray.count < 1){
            currentRocketsLabel.text = @"Current Rockets: 0";
        }
        else{
            currentRocketsLabel.text = @"Current Rockets";
        }
    }
    if (section == 1) {
        currentRocketsLabel.text = @"Past Rockets";
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    
    if ([segue.identifier isEqualToString:@"showRocketDetail"]) {
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        IRDMapZoomViewController *zoomView = segue.destinationViewController;
        
        
        NSArray *rocketArray = @[];
        
        if(indexPath.section == 0){
            rocketArray = self.currentAlertIDs.copy;
        }else if(indexPath.section == 1){
            rocketArray = self.pastAlertIDs.copy;
        }
        
        NSNumber *currentAlertID = rocketArray[indexPath.row];
        zoomView.alertID = currentAlertID;
        
    }
}


@end
