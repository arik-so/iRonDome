//
//  IRDMapZoomViewController.m
//  iRonDome
//
//  Created by Ben Honig on 7/19/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDMapZoomViewController.h"
#define kMapZoomLatitude 400000
#define kMapZoomLongitude 400000
#define kRocketZoomLatitude 5000
#define kRocketZoomLongitude 5000

#define MAP_PADDING 1.3
#define MINIMUM_VISIBLE_LATITUDE 0.01

@interface IRDMapZoomViewController ()

@property (strong, nonatomic) NSMutableArray *sirens;

@end

@implementation IRDMapZoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sirens = @[].mutableCopy;
    
    
    NSString *dbTable = [SCLocalSiren getDatabaseTable];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE alertID = :alertID ORDER BY timestamp DESC, toponym ASC", dbTable];
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query withParameterDictionary:@{@"alertID": self.alertID}];
        
        while([result next]){
            
            SCLocalSiren *currentSiren = [[SCLocalSiren alloc] init];
            [currentSiren initWithFetchResponse:result.resultDictionary];
            
            [self.sirens addObject:currentSiren];
            
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
    
    }];
    
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
}



- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
    circleView.strokeColor = [UIColor blackColor];
    // [circleView setAlpha:0.5f];
    return circleView;
}



/* - (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
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
                id<MKAnnotation> mp = [view annotation];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], kRocketZoomLatitude, kRocketZoomLongitude);
                
                [mv setRegion:region animated:YES];
            }];
        }
    }
} */


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
