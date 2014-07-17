//
//  IRDMapAnnotation.h
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface IRDMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

@property (nonatomic, copy) NSString *rocketId;

-(void)initWithCoordinate:(CLLocationCoordinate2D) theCoordinate userTitle:(NSString *) theTitle userSubtitle:(NSString *) theSubTitle;

@end

