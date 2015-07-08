//
//  IRDSingleRocketTableViewController.h
//  iRonDome
//
//  Created by Arik Sosman on 7/24/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "IRDMapAnnotation.h"

#import "IRDImpactCalculator.h"

@interface IRDSingleRocketTableViewController : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSNumber *alertID;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end
