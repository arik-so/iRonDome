//
//  SCLocalObject.h
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "SCSQLiteManager.h"

@interface SCLocalObject : NSObject

@property (readonly) long identifier;
@property (readonly) BOOL doingIntervalIO;

+ (NSArray *)fetchAll;

+ (instancetype)fetchByLocalID:(int)localID;
+ (instancetype)fetchByServerID:(NSString *)serverID;
+ (instancetype)fetchByUniqueID:(NSString *)uniqueID;

+ (NSArray *)idsToObjects:(NSArray *)ids;
+ (NSArray *)objectsToIDs:(NSArray *)objects;

+ (NSString *)getDatabaseTable;

+ (instancetype)create;
- (void)remove;

- (void)reload;
- (void)initWithFetchResponse:(NSDictionary *)response;

- (void)saveAttribute:(NSString *)attribute;
- (void)saveAttributes:(NSArray *)attributes;

+ (NSString *)saveAttributeValueToFile:(NSString *)value;
+ (NSString *)getAttributeValueFromFile:(NSString *)path;

// returns the relevant encrypted dictionary that can be sent to the server when something new is created
- (NSDictionary *)encryptForServer;

// returns the array of modified attributes
- (NSArray *)decryptFromServer:(NSDictionary *)encryptedDictionary;

@end

#import "SCLocalRocket.h"
#import "SCLocalSiren.h"

/* #import "SCLocalUser.h"
#import "SCLocalConversation.h"
#import "SCLocalMessage.h"
#import "SCLocalUserConversation.h"
#import "SCLocalReadReceipt.h"
#import "SCLocalUserDatum.h" */