//
//  IRDImpactCalculator.h
//  iRonDome
//
//  Created by Arik Sosman on 7/20/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "iRonDome-Swift.h"

@interface IRDImpactCalculator : NSObject

+ (MKCoordinateRegion)determineSirenBounds:(Siren *)siren;
+ (MKCoordinateRegion)determineImpactBoundsForSirens:(NSArray *)sirens;
+ (CLLocationDistance)determineImpactRadiusForSiren:(Siren *)siren;

@end
