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

@interface IRDMapZoomViewController ()

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
    
    [self setupMap];
    
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = self.latitude;
    ctrpoint.longitude = self.longitude;
    IRDMapAnnotation *rocketAnnotation = [[IRDMapAnnotation alloc] init];
    [rocketAnnotation initWithCoordinate:ctrpoint userTitle:@"Rocket" userSubtitle:[NSString stringWithFormat:@"%f;%f", self.latitude, self.longitude]];
    
    [self.mapView addAnnotation:rocketAnnotation];
}

- (void)setupMap{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 31.0000;
    zoomLocation.longitude= 35.0000;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, kMapZoomLatitude, kMapZoomLongitude);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];

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
                id<MKAnnotation> mp = [view annotation];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], kRocketZoomLatitude, kRocketZoomLongitude);
                
                [mv setRegion:region animated:YES];
            }];
        }
    }
}


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
