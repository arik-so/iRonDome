//
//  IRDImpactCalculator.m
//  iRonDome
//
//  Created by Arik Sosman on 7/20/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDImpactCalculator.h"

@implementation IRDImpactCalculator

+ (MKCoordinateRegion)determineSirenBounds:(NSArray *)sirens{
    
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    NSDate *sirenTime = nil;
    
    for(SCLocalSiren *currentSiren in sirens){
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.latitudeNorth;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.latitudeNorth);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.latitudeSouth;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.latitudeSouth);
        }
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.longitudeEast;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.longitudeEast);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.longitudeWest;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.longitudeWest);
        }
        
        if(!sirenTime){
            sirenTime = [NSDate dateWithTimeIntervalSince1970:currentSiren.timestamp];
        }
        
    }
    
    CLLocationDegrees centralLatitude = (latitudeNorth + latitudeSouth) * 0.5;
    CLLocationDegrees centralLongitude = (longitudeEast + longitudeWest) * 0.5;
    
    CLLocationDegrees latitudeDelta = ABS(latitudeNorth - latitudeSouth);
    CLLocationDegrees longitudeDelta = ABS(longitudeWest - longitudeEast);
    
    
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(centralLatitude, centralLongitude);
    region.span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    
    return region;
    
}

+ (MKCoordinateRegion)determineImpactBoundsForSirens:(NSArray *)sirens{
    
    MKCoordinateRegion bounds = [self determineSirenBounds:sirens];
    
    CLLocationDegrees diameter = sqrt(pow(bounds.span.latitudeDelta, 2) + pow(bounds.span.longitudeDelta, 2));
    bounds.span.latitudeDelta = diameter;
    bounds.span.longitudeDelta = diameter;
    
    return bounds;
    
}

+ (CLLocationDistance)determineImpactRadiusForSirens:(NSArray *)sirens{
    
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    for(SCLocalSiren *currentSiren in sirens){
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.latitudeNorth;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.latitudeNorth);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.latitudeSouth;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.latitudeSouth);
        }
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.longitudeEast;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.longitudeEast);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.longitudeWest;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.longitudeWest);
        }
        
    }

    CLLocation *edgeSW = [[CLLocation alloc] initWithLatitude:latitudeSouth longitude:longitudeWest];
    CLLocation *edgeNE = [[CLLocation alloc] initWithLatitude:latitudeNorth longitude:longitudeEast];
    
    return [edgeSW distanceFromLocation:edgeNE] * 0.5;
    
}

@end
