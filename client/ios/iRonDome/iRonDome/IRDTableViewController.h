//
//  IRDTableViewController.h
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "IRDMapAnnotation.h"
#import "IRDSingleRocketTableViewController.h"
#import "CustomTableViewCell.h"

@interface IRDTableViewController : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong)NSMutableArray *rocketData;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSURLSession *session;

@end
