//
//  SCSQLiteManager.h
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface SCSQLiteManager : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue *dbQueue;

+ (SCSQLiteManager *)getActiveManager;
+ (void)setActiveManager:(SCSQLiteManager *)manager;
+ (void)clearActiveManager;

+ (SCSQLiteManager *)initManager;

- (long)createObjectInTable:(NSString *)table;

- (NSDictionary *)fetchObjectByID:(int)identifier inTable:(NSString *)table;
- (NSDictionary *)fetchObjectByServerID:(int)serverID inTable:(NSString *)table;
- (NSDictionary *)fetchObjectByProperty:(NSString *)property withValue:(NSString *)value inTable:(NSString *)table;

@end
