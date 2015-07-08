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

@property (readwrite) NSTimeInterval timestamp;

@end

@implementation SCLocalSiren

+ (NSString *)getDatabaseTable { return @"sirens"; }

- (void)initFromServerResponse:(NSDictionary *)serverSiren{
    
    self.serverID = serverSiren[@"alert_id"];
    self.timestamp = [serverSiren[@"timestamp"] longLongValue];
    
    [self saveAttributes:@[@"serverID", @"timestamp"]];
    
}

@end
