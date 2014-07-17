//
//  SCSQLiteManager.m
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

#import "SCSQLiteManager.h"

@interface SCSQLiteManager()

// @property (readwrite) FMDatabase *dbObject;

@property (strong, nonatomic) NSString *dbPath;
@property (readwrite) FMDatabaseQueue *dbQueue;

@end

@implementation SCSQLiteManager

static SCSQLiteManager *activeManager;

+ (SCSQLiteManager *)getActiveManager{ return activeManager; }
+ (void)setActiveManager:(SCSQLiteManager *)manager{ activeManager = manager; }
+ (void)clearActiveManager{ activeManager = nil; }

+ (SCSQLiteManager *)initManager{
    
    if(![NSThread isMainThread]){ return nil; }
    
    SCSQLiteManager *manager = [self new];
    
    NSString *path = [self databasePath];
        
    // manager.dbObject = [FMDatabase databaseWithPath:path];
    // if(![manager.dbObject open]){ return nil; }
    
    manager.dbPath = path;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    manager.dbQueue = queue;
    
    [manager initDatabase];
    
    return manager;
    
}

+ (NSString *)databasePath{
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = searchPaths[0];
    // NSString *hiddenDirectory = [NSBundle mainBundle].resourcePath;
    
    NSString *pathComponent = @".data/.rockets.sqlite";
    NSString *path = [documentPath stringByAppendingPathComponent:pathComponent];

    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *pathDirectory = [path stringByDeletingLastPathComponent];
    
    if(![fm fileExistsAtPath:pathDirectory]){
        [fm createDirectoryAtPath:pathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
    
}

- (void)initDatabase{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        // the primary keys need to be added with the creation process
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS rockets (id INTEGER PRIMARY KEY AUTOINCREMENT)"];
        
        
        
        // initializing the users table

        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN serverID TEXT "]; // the object's server ID as on parse
        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN latitude FLOAT "];
        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN longitude FLOAT "];
        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN toponym TEXT "]; // like place name, but more fancy
        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN alertID INTEGER (20) "];
        [db executeUpdate:@"ALTER TABLE rockets ADD COLUMN timestamp INTEGER (20) "];
        
        
        
    }];
    
    NSLog(@"DB is now initialized");
    
}

- (long)createObjectInTable:(NSString *)table{
    
    NSString *queryString = [NSString stringWithFormat:@"INSERT INTO %@ DEFAULT VALUES", table];
    
    NSString *fetchString = [NSString stringWithFormat:@"SELECT LAST_INSERT_ROWID() FROM %@", table];
    
    NSMutableArray *resultArray = @[].mutableCopy;
    
    [self.dbQueue inDatabase:^(FMDatabase *db){
    
        [db executeUpdate:queryString]; // now we have created the object
        
        FMResultSet *result = [db executeQuery:fetchString];
        
        if(result.next){
            
            [resultArray addObject:result.resultDictionary];
            
        }
        
        [result close];
        
        // if(!result.next){ return -1; }
        
    }];

    if(resultArray.count < 1){ return -1; }
    
    NSDictionary *resultDictionary = resultArray.firstObject;
    
    NSNumber *insertionID = resultDictionary[@"LAST_INSERT_ROWID()"];
    
    return insertionID.longValue;
    
}


// this function is useful for stuff like fetch by unique id or what not
- (NSDictionary *)fetchObjectByProperty:(NSString *)property withValue:(NSString *)value inTable:(NSString *)table{
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = :%@", table, property, property];
    
    NSDictionary *values = @{property: value};
    
    NSMutableArray *resultArray = @[].mutableCopy;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:queryString withParameterDictionary:values];
        
        if(result.next){
            [resultArray addObject:result.resultDictionary];
        }
        
        [result close];
        
    }];
    
    if(resultArray.count < 1){ return nil; } // it should have never been here
    
    return resultArray.firstObject;

    
}

- (NSDictionary *)fetchObjectByID:(int)identifier inTable:(NSString *)table{
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = %i", table, identifier];
    
    NSMutableArray *resultArray = @[].mutableCopy;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:queryString];
        
        if(result.next){
            [resultArray addObject:result.resultDictionary];
        }
        
        [result close];
        
    }];
    
    if(resultArray.count < 1){ return nil; } // it should have never been here
    
    return resultArray.firstObject;
    
}

- (NSDictionary *)fetchObjectByServerID:(NSString *)serverID inTable:(NSString *)table{
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE serverID = %@", table, serverID];
    
    NSMutableArray *resultArray = @[].mutableCopy;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:queryString];
        
        if(result.next){
            [resultArray addObject:result.resultDictionary];
        }
        
        [result close];
        
    }];
    
    if(resultArray.count < 1){ return nil; } // it should have never been here
    
    return resultArray.firstObject;
    
}

@end
