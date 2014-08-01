//
//  InAppObserver.h
//  iRonDome
//
//  Created by Ben Honig on 7/31/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppObserver : NSObject <SKPaymentTransactionObserver> {
    
    
    
}


-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;


@end
