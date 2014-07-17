//
//  SCLocalConversation.m
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

#import "SCLocalRocket.h"

@interface SCLocalRocket()

@property (readwrite) NSString *serverID;

@property (readwrite) double latitude;
@property (readwrite) double longitude;
@property (readwrite) NSTimeInterval timestamp;
@property (readwrite) long long alertID;

@end

@implementation SCLocalRocket

+ (NSString *)getDatabaseTable { return @"rockets"; }

- (void)initFromServerResponse:(PFObject *)serverRocket{
    
    PFGeoPoint *location = serverRocket[@"location"];
    
    self.serverID = serverRocket.objectId;
    
    self.latitude = location.latitude;
    self.longitude = location.longitude;
    self.timestamp = serverRocket.createdAt.timeIntervalSince1970;
    self.alertID = [serverRocket[@"alertID"] longLongValue];
    
    [self saveAttributes:@[@"serverID", @"latitude", @"longitude", @"timestamp", @"alertID"]];
        
}




@end
