//
//  IRDMapZoomViewController.h
//  iRonDome
//
//  Created by Ben Honig on 7/19/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "IRDMapAnnotation.h"

@interface IRDMapZoomViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;

@end
