//
//  IRDImpactCalculator.m
//  iRonDome
//
//  Created by Arik Sosman on 7/20/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDImpactCalculator.h"



@implementation IRDImpactCalculator

+ (MKCoordinateRegion)determineSirenBounds:(Siren *)siren{
    
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    NSDate *sirenTime = siren.timestamp;
    
    for(Area *currentSiren in siren.areas.allObjects){
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.northEdgeLatitude.doubleValue;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.northEdgeLatitude.doubleValue);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.southEdgeLatitude.doubleValue;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.southEdgeLatitude.doubleValue);
        }
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.eastEdgeLongitude.doubleValue;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.eastEdgeLongitude.doubleValue);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.westEdgeLongitude.doubleValue;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.westEdgeLongitude.doubleValue);
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

+ (MKCoordinateRegion)determineImpactBoundsForSirens:(Siren *)sirens{
    
    MKCoordinateRegion bounds = [self determineSirenBounds:sirens];
    
    CLLocationDegrees diameter = sqrt(pow(bounds.span.latitudeDelta, 2) + pow(bounds.span.longitudeDelta, 2));
    bounds.span.latitudeDelta = diameter;
    bounds.span.longitudeDelta = diameter;
    
    return bounds;
    
}

+ (CLLocationDistance)determineImpactRadiusForSirens:(Siren *)siren{
    
    double latitudeNorth = -1;
    double latitudeSouth = -1;
    double longitudeWest = -1;
    double longitudeEast = -1;
    
    for(Area *currentSiren in siren.areas.allObjects){
        
        if(latitudeNorth == -1){
            latitudeNorth = currentSiren.northEdgeLatitude.doubleValue;
        }else{
            latitudeNorth = MAX(latitudeNorth, currentSiren.northEdgeLatitude.doubleValue);
        }
        
        if(latitudeSouth == -1){
            latitudeSouth = currentSiren.southEdgeLatitude.doubleValue;
        }else{
            latitudeSouth = MIN(latitudeSouth, currentSiren.southEdgeLatitude.doubleValue);
        }
        
        if(longitudeEast == -1){
            longitudeEast = currentSiren.eastEdgeLongitude.doubleValue;
        }else{
            longitudeEast = MAX(longitudeEast, currentSiren.eastEdgeLongitude.doubleValue);
        }
        
        if(longitudeWest == -1){
            longitudeWest = currentSiren.westEdgeLongitude.doubleValue;
        }else{
            longitudeWest = MIN(longitudeWest, currentSiren.westEdgeLongitude.doubleValue);
        }
        
    }

    CLLocation *edgeSW = [[CLLocation alloc] initWithLatitude:latitudeSouth longitude:longitudeWest];
    CLLocation *edgeNE = [[CLLocation alloc] initWithLatitude:latitudeNorth longitude:longitudeEast];
    
    return [edgeSW distanceFromLocation:edgeNE] * 0.5;
    
}

@end
