//
//  SCLocalConversation.h
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

// @class SCLocalObject;

#import "SCLocalObject.h"


@interface SCLocalRocket : SCLocalObject

@property (strong, nonatomic, readonly) NSString *serverID;

@property (readonly) double latitude;
@property (readonly) double longitude;
@property (readonly) NSTimeInterval timestamp;
@property (readonly) long long alertID;

@property (strong, nonatomic) NSString *toponym;

- (void)initFromServerResponse:(PFObject *)serverRocket;

@end
