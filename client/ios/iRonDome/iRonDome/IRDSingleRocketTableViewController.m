//
//  IRDSingleRocketTableViewController.m
//  iRonDome
//
//  Created by Arik Sosman on 7/24/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDSingleRocketTableViewController.h"

#define MAP_PADDING 1.3
#define MINIMUM_VISIBLE_LATITUDE 0.01

#define kAvenirLight @"Avenir-Light"
#define kAvenirBook @"Avenir-Book"

@interface IRDSingleRocketTableViewController ()

@property (strong, nonatomic) NSMutableArray *sirens;

@end

@implementation IRDSingleRocketTableViewController

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
    
    [self loadSirens];
    [self prepareMap];
    
    self.tableView.tableHeaderView = self.mapView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)loadSirens{
    
    self.sirens = @[].mutableCopy;
    
    NSString *dbTable = [SCLocalSiren getDatabaseTable];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE alertID = :alertID ORDER BY toponym ASC", dbTable];
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query withParameterDictionary:@{@"alertID": self.alertID}];
        
        while([result next]){
            
            SCLocalSiren *currentSiren = [[SCLocalSiren alloc] init];
            [currentSiren initWithFetchResponse:result.resultDictionary];
            
            [self.sirens addObject:currentSiren];
            
        }
        
    }];
    
}

- (void)prepareMap{
    
    for(SCLocalSiren *currentSiren in self.sirens){
        
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = currentSiren.latitude;
        ctrpoint.longitude = currentSiren.longitude;
        NSString *placeLabel = @"";
        placeLabel = [NSString stringWithFormat:@"%@, %@", placeLabel, currentSiren.toponym];
        placeLabel = [placeLabel substringFromIndex:2];
        IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
        [rocketAnnotation initWithCoordinate:ctrpoint userTitle:@"Siren" userSubtitle:placeLabel];
        
        [self.mapView addAnnotation:rocketAnnotation];
        
    }
    
    MKCoordinateRegion rocketBounds = [IRDImpactCalculator determineImpactBoundsForSirens:self.sirens];
    MKCoordinateRegion region = rocketBounds;
    // region.center.latitude = (latitudeSouth + latitudeNorth) / 2;
    // region.center.longitude = (longitudeWest + longitudeEast) / 2;
    
    region.span.latitudeDelta *= MAP_PADDING;
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE) ? MINIMUM_VISIBLE_LATITUDE : region.span.latitudeDelta;
    region.span.longitudeDelta *= MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:scaledRegion animated:YES];
    
    
    // add the projected rocket impact
    
    /* IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
     [rocketAnnotation initWithCoordinate:rocketBounds.center userTitle:@"Projected Impact" userSubtitle:nil];
     [self.mapView addAnnotation:rocketAnnotation]; */
    
    
    CLLocationDistance impactRadius = [IRDImpactCalculator determineImpactRadiusForSirens:self.sirens];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:rocketBounds.center radius:impactRadius];
    [self.mapView addOverlay:circle];
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
    circleView.strokeColor = [UIColor blackColor];
    // [circleView setAlpha:0.5f];
    return circleView;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.sirens.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    SCLocalSiren *currentSiren = self.sirens[indexPath.row];
    
    // Configure the cell...
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text = currentSiren.toponym;
    
    //TODO: animate Siren
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] init];
    
    headerView.frame = CGRectMake(0, 0, 320, 20);
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1.0];
    UILabel *sirensLabel = [[UILabel alloc] init];
    sirensLabel.frame = CGRectMake(20, 10, 320, 21);
    sirensLabel.font = [UIFont fontWithName:kAvenirBook size:16];
    sirensLabel.textAlignment = NSTextAlignmentLeft;
    sirensLabel.textColor = [UIColor blackColor];
    [headerView addSubview:sirensLabel];
    
    sirensLabel.text = NSLocalizedString(@"sirens", nil);
    
    return headerView;
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
