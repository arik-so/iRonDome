//
//  IRDMapAnnotation.m
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDMapAnnotation.h"

@implementation IRDMapAnnotation

-(void)initWithCoordinate:(CLLocationCoordinate2D) theCoordinate userTitle:(NSString *) theTitle userSubtitle:(NSString *) theSubTitle{
    _coordinate = theCoordinate;
    _title = theTitle;
    _subtitle = theSubTitle;
}

@end
