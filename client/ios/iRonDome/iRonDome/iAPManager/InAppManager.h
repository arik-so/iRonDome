//
//  InAppManager.h
//  iRonDome
//
//  Created by Ben Honig on 7/31/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "InAppObserver.h"

@interface InAppManager : NSObject <SKProductsRequestDelegate> {
    
    
    
}


+(InAppManager*) sharedManager;


-(void) buyRemoveAds; // declared so any class call this and initiate purchasing remove ads


-(bool) isRemoveAdsPurchasedAlready; // declared so any class can check if remove ads was purchased prior to doing something


-(void) restoreCompletedTransactions; // if you sell non-consumable purchases you MUST give people the option to RESTORE.

-(void) failedTransaction:(SKPaymentTransaction*) transaction;
-(void) provideContent:(NSString*) productIdentifier; 

@end
