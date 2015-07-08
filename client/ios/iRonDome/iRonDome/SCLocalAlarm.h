//
//  SCLocalAlarm.h
//  iRonDome
//
//  Created by Arik Sosman on 7/8/15.
//  Copyright (c) 2015 Arik. All rights reserved.
//

#import "SCLocalObject.h"

@interface SCLocalAlarm : SCLocalObject

@property (strong, nonatomic, readonly) NSString *serverID;

@property (readonly) double latitude;
@property (readonly) double longitude;

@property (readonly) double latitudeNorth;
@property (readonly) double latitudeSouth;

@property (readonly) double longitudeWest;
@property (readonly) double longitudeEast;

@property (readonly) NSTimeInterval timestamp;

@property (strong, nonatomic) NSString *toponymShort;
@property (strong, nonatomic) NSString *toponymLong;

- (void)initFromServerResponse:(PFObject *)serverSiren;

@end
