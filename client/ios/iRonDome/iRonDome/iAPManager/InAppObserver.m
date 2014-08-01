//
//  InAppObserver.m
//  iRonDome
//
//  Created by Ben Honig on 7/31/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//


#import "InAppObserver.h"
#import "InAppManager.h"  // be sure you don't import this in the header file of this class

@implementation InAppObserver



-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    

    for(SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
        
    }
    
}

-(void)failedTransaction:(SKPaymentTransaction*) transaction {
    NSLog(@"Transaction Failed");
    
    //if the error was anything other than the user cancelling it

    if (transaction.error.code != SKErrorPaymentCancelled) {
        
        [[InAppManager sharedManager] failedTransaction:transaction];
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    

}

-(void)completeTransaction:(SKPaymentTransaction*) transaction {
    NSLog(@"Transaction Completion");
    
    //when we pass the transaction back to the sharedManager it has the product ID
    [[InAppManager sharedManager] provideContent:transaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction*) transaction {
    NSLog(@"Transaction Restored");
    
     [[InAppManager sharedManager] provideContent:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
