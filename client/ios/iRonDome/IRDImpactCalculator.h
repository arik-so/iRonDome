//
//  IRDImpactCalculator.h
//  iRonDome
//
//  Created by Arik Sosman on 7/20/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface IRDImpactCalculator : NSObject

+ (MKCoordinateRegion)determineSirenBounds:(NSArray *)sirens;
+ (MKCoordinateRegion)determineImpactBoundsForSirens:(NSArray *)sirens;
+ (CLLocationDistance)determineImpactRadiusForSirens:(NSArray *)sirens;

@end
