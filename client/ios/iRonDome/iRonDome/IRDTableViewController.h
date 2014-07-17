//
//  IRDTableViewController.h
//  iRonDome
//
//  Created by Arik Sosman on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "IRDMapAnnotation.h"

@interface IRDTableViewController : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@end
