//
//  SCLocalObject.m
//  SecuChat
//
//  Created by Arik Sosman on 3/8/14.
//  Copyright (c) 2014 Sosman & Perk. All rights reserved.
//

#import "SCLocalObject.h"

@interface SCLocalObject()

@property (readwrite) long identifier;
@property (readwrite) BOOL doingIntervalIO;

@end

@implementation SCLocalObject

+ (NSArray *)fetchAll{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return nil; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self getDatabaseTable];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", dbTable];
    
    NSMutableArray *results = @[].mutableCopy;
    
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:query];
        
        while(result.next){
            
            SCLocalObject *instance = [self new];
            [instance initWithFetchResponse:result.resultDictionary];
            
            [results addObject:instance];
            
        }
        
    }];
    
    return results.copy;
    
}

+ (instancetype)fetchByLocalID:(int)localID{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return nil; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self getDatabaseTable];
    
    NSDictionary *response = [manager fetchObjectByID:localID inTable:dbTable];
    
    if(!response){ return nil; }
    
    SCLocalObject *instance = [self new];
    
    [instance initWithFetchResponse:response];
    
    return instance;
    
}

+ (instancetype)fetchByServerID:(NSString *)serverID{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return nil; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self getDatabaseTable];
    
    NSDictionary *response = [manager fetchObjectByServerID:serverID inTable:dbTable];
    
    if(!response){ return nil; }
    
    SCLocalObject *instance = [self new];
    
    [instance initWithFetchResponse:response];
    
    return instance;
    
}

+ (instancetype)fetchByUniqueID:(NSString *)uniqueID{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return nil; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self getDatabaseTable];
    
    NSDictionary *response = [manager fetchObjectByProperty:@"uniqueID" withValue:uniqueID inTable:dbTable];
    
    if(!response){ return nil; }
    
    SCLocalObject *instance = [self new];
    
    [instance initWithFetchResponse:response];
    
    return instance;
    
}

+ (instancetype)create{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return nil; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self getDatabaseTable];
    
    long identifier = [manager createObjectInTable:dbTable]; // this is the ID of the newly created object
    
    SCLocalObject *instance = [self new];
    
    instance.identifier = identifier;
    
    return instance;
    
}

- (void)remove{
    
    if(self.class == [SCLocalObject class]){ return; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self.class getDatabaseTable];
    
    long identifier = self.identifier;
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = :identifier", dbTable];
    
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:query withParameterDictionary:@{@"identifier": @(identifier)}];
    }];
    
}

- (void)reload{
    
    if(self.class == [SCLocalObject class]){ return; } // this is a pseudo-abstract class, motherfuckers!
    
    SCSQLiteManager *manager = [SCSQLiteManager getActiveManager];
    
    if(!manager){ return; } // there is obviously nothing interesting at this point
    
    NSString *dbTable = [self.class getDatabaseTable];
    
    NSDictionary *response = [manager fetchObjectByID:self.identifier inTable:dbTable];
    
    [self initWithFetchResponse:response];
    
}

- (void)initWithFetchResponse:(NSDictionary *)response{
    
    if(self.class == [SCLocalObject class]){ return; } // this is a pseudo-abstract class, motherfuckers!
    
    self.doingIntervalIO = YES;
    
    for(NSString *key in response){
        
        id value = response[key];
        
        if([value isKindOfClass:[NSNull class]]){ continue; } // we don't want/need nulls, correct?
        
        if([key isEqualToString:@"id"]){
            
            [self setValue:value forKey:@"identifier"];
            
            continue; // we need the identifier to save stuff properly :D
            
        }
        
        SEL getter = NSSelectorFromString(key);
        
        if([self respondsToSelector:getter]){
            
            @try{
                
                if([value isKindOfClass:[NSNull class]]){
                
                    [self setNilValueForKey:key];
                    
                    continue;
                    
                }
                
                [self setValue:value forKey:key];
                
            }@catch(NSException *e){
            
                NSLog(@"Getter, but no setter for %@", key);
                
            }
            
        }else{
            
            NSLog(@"No getter (and subsequently no setter) for %@", key);
            
        }
        
    }
    
    self.doingIntervalIO = NO;
    
}

- (void)saveAttribute:(NSString *)attribute{

    [self saveAttributes:@[attribute]];
    
}

- (void)saveAttributes:(NSArray *)attributes{
    
    if(self.class == [SCLocalObject class]){ return; } // this is a pseudo-abstract class, motherfuckers!
    
    if(!attributes){ return; }
    
    if(attributes.count < 1){ return; } // there is nothing to save
    
    NSMutableDictionary *values = @{}.mutableCopy;
    
    NSString *updateString = @"";
    
    self.doingIntervalIO = YES;
    
    for(NSString *currentAttribute in attributes){
        
        SEL getter = NSSelectorFromString(currentAttribute);
        
        if([self respondsToSelector:getter]){
        
            id value = [self valueForKey:currentAttribute];
            
            if(!value){ // this value is nil
            
                value = [NSNull null];
            
            }
            
            values[currentAttribute] = value;
            updateString = [NSString stringWithFormat:@"%@, %@ = :%@", updateString, currentAttribute, currentAttribute];
            
        }else{
            
            NSLog(@"No getter for %@", currentAttribute);
            
        }
        
    }
    
    self.doingIntervalIO = NO;
    
    if(values.count < 1){ return; } // there is nothing to save
    
    values[@"identifier"] = @(self.identifier);
    
    updateString = [updateString substringFromIndex:2]; // we don't need the ", " at the beginning
    
    // FMDatabase *db = [SCSQLiteManager getActiveManager].dbObject;
    
    NSString *dbTable = [self.class getDatabaseTable];
    
    NSString *queryString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE id = :identifier", dbTable, updateString];
    
    [[SCSQLiteManager getActiveManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        BOOL couldUpdate = [db executeUpdate:queryString withParameterDictionary:values];
        
        if(!couldUpdate){
            
            NSString *error = [db lastErrorMessage];
            
            NSLog(@"Could not update object because:\n%@", error);
            
        }
        
    }];
    
}

- (NSArray *)decryptFromServer:(NSDictionary *)encryptedDictionary{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    // the server dictioary almost always send an ID
    
    SEL serverIDSelector = NSSelectorFromString(@"serverID");
    
    if(encryptedDictionary[@"id"]){
        
        id serverID = encryptedDictionary[@"id"];
        
        if([serverID respondsToSelector:@selector(intValue)] && [self respondsToSelector:serverIDSelector]){
            
            // did it have a value before that?
            
            id previousValue = [self valueForKey:@"serverID"];
            
            if(previousValue && [previousValue respondsToSelector:@selector(intValue)]){
                
                if([previousValue intValue] == [serverID intValue]){
                    
                    return @[];
                    
                }
                
                if([previousValue intValue] > 0){ return nil; } // something has gone horribly wrong
                
            }
            
            
            
            [self setValue:@([serverID intValue]) forKey:@"serverID"];
            
            return @[@"serverID"];
            
        }
        
    }
    
    return @[];
    
}

+ (NSArray *)objectsToIDs:(NSArray *)objects{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    NSMutableArray *ids = @[].mutableCopy;
    
    for(SCLocalObject *object in objects){
        
        [ids addObject:@(object.identifier)];
        
    }
    
    return ids.copy;
    
}

+ (NSArray *)idsToObjects:(NSArray *)ids{
    
    if(self.class == [SCLocalObject class]){ return nil; } // this is a pseudo-abstract class, motherfuckers!
    
    NSMutableArray *objects = @[].mutableCopy;
    
    for(NSNumber *currentID in ids){
        
        [objects addObject:[self fetchByLocalID:currentID.intValue]]; // integers, to be safe
        
    }
    
    return objects.copy;
    
}

@end
