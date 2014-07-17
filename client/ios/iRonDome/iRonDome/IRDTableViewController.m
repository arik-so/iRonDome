//
//  IRDTableViewController.m
//  iRonDome
//
//  Created by Arik Sosman on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDTableViewController.h"

#define kRocketTimeThreshold -60*400
#define kMapZoomLatitude 400000
#define kMapZoomLongitude 400000
#define kAvenirLight @"Avenir-Light"

@interface IRDTableViewController ()


@property (nonatomic, strong)NSMutableArray *rocketData;
@property (nonatomic, weak) IBOutlet MKMapView *mapViewOld;
@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CLGeocoder *geocoder;




@property (strong, nonatomic) NSMutableArray *currentRockets;
@property (strong, nonatomic) NSMutableArray *pastRockets;



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
    
    
    //init array to store data in
    self.rocketData = [[NSMutableArray alloc] init];
    
    self.currentRockets = @[].mutableCopy;
    self.pastRockets = @[].mutableCopy;
    
    
    
    //download rocket data
    [self downloadRocketData];
    
    [self setupMap];
    
    // [self performSelector:@selector(testTableView) withObject:nil afterDelay:5];
    
    
    
    
    UIRefreshControl *refresher = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refresher];
    
    
    
}





// blindly added code

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
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    [self.mapView setRegion:viewRegion animated:YES];
    
    self.tableView.tableHeaderView = self.mapView;
    
    // [_mapView setRegion:viewRegion animated:YES];
}

- (void)downloadRocketData{
    
    PFQuery *currentRocketQuery = [PFQuery queryWithClassName:@"Rocket"];
    [currentRocketQuery whereKey:@"createdAt" greaterThanOrEqualTo:[[NSDate date] dateByAddingTimeInterval:kRocketTimeThreshold]];
    
    
    PFQuery *pastRocketQuery = [PFQuery queryWithClassName:@"Rocket"];
    [pastRocketQuery whereKey:@"createdAt" lessThan:[[NSDate date] dateByAddingTimeInterval:kRocketTimeThreshold]];
    
    
    
    
    // [query whereKey:@"createdAt" equalTo:[NSNull null]];
    //[query whereKey:@"createdAt" equalTo:[self todaysDate]];
    [currentRocketQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu rockets.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                PFGeoPoint *location = object[@"location"];
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
                });
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // [self testTableView];
                
                [self.tableView reloadData];
                
            });
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    

    
    
    
    [pastRocketQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu rockets.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                PFGeoPoint *location = object[@"location"];
                NSLog(@"Object Id: %@ Latitude: %f Longitude: %f", object.objectId, location.latitude, location.longitude);
                
                [self.pastRockets addObject:[NSArray arrayWithObjects:object.objectId, [NSNumber numberWithDouble:location.latitude], [NSNumber numberWithDouble:location.longitude], nil]];
                
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // [self testTableView];
                
                [self.tableView reloadData];
                
            });
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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
    
    // return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section == 0){
        return self.currentRockets.count;
    }else if(section == 1){
        return self.pastRockets.count;
    }
    
    return 0;
    
    // return [self.rocketData count];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 70;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    NSArray *rocketArray = @[];
    
    if(indexPath.section == 0){
        rocketArray = self.currentRockets.copy;
    }else if(indexPath.section == 1){
        rocketArray = self.pastRockets.copy;
    }
    
    
    // Configure the cell...
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    if (rocketArray.count == 0) {
        //dont set the text yet
    }
    else{
        subtitleLabel.text = [NSString stringWithFormat:@"%f, %f",[rocketArray[indexPath.row][1] doubleValue], [rocketArray[indexPath.row][2] doubleValue]];
    }
    
    return cell;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 0 && self.currentRockets.count > 0){
        
        return @"Current Rockets";
        
    }else if(section == 1 && self.pastRockets.count > 0){
    
        return @"Past Rockets";
        
    }
    
    return nil;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
