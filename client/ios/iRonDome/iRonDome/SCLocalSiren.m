//
//  SCLocalSiren.m
//  iRonDome
//
//  Created by Arik Sosman on 7/19/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "SCLocalSiren.h"

@interface SCLocalSiren()

@property (readwrite) NSString *serverID;

@property (readwrite) double latitude;
@property (readwrite) double longitude;

@property (readwrite) double latitudeNorth;
@property (readwrite) double latitudeSouth;

@property (readwrite) double longitudeWest;
@property (readwrite) double longitudeEast;

@property (readwrite) NSTimeInterval timestamp;
@property (readwrite) long long alertID;

@end

@implementation SCLocalSiren

+ (NSString *)getDatabaseTable { return @"sirens"; }

- (void)initFromServerResponse:(PFObject *)serverSiren{
    
    PFGeoPoint *location = serverSiren[@"location"];
    PFGeoPoint *edgeNE = serverSiren[@"edgeNE"];
    PFGeoPoint *edgeSW = serverSiren[@"edgeSW"];
    
    self.serverID = serverSiren.objectId;
    
    self.latitude = location.latitude;
    self.longitude = location.longitude;
    
    self.latitudeNorth = edgeNE.latitude;
    self.latitudeSouth = edgeSW.latitude;
    
    self.longitudeWest = edgeSW.longitude;
    self.longitudeEast = edgeNE.longitude;
    
    self.timestamp = serverSiren.createdAt.timeIntervalSince1970;
    self.alertID = [serverSiren[@"alertID"] longLongValue];
    
    [self saveAttributes:@[@"serverID", @"latitude", @"longitude", @"latitudeNorth", @"latitudeSouth", @"longitudeWest", @"longitudeEast", @"timestamp", @"alertID"]];
    
}

@end
