//
//  SCLocalSiren.h
//  iRonDome
//
//  Created by Arik Sosman on 7/19/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "SCLocalObject.h"

@interface SCLocalSiren : SCLocalObject

@property (strong, nonatomic, readonly) NSString *serverID;

@property (readonly) NSTimeInterval timestamp;
@property (readonly) long long alertID;



@property (readonly) double latitude;
@property (readonly) double longitude;

@property (readonly) double latitudeNorth;
@property (readonly) double latitudeSouth;

@property (readonly) double longitudeWest;
@property (readonly) double longitudeEast;

@property (strong, nonatomic) NSString *toponym;



- (void)initFromServerResponse:(NSDictionary *)serverSiren;

@end
