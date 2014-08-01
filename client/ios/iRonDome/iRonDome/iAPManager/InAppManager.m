//
//  InAppManager.m
//  iRonDome
//
//  Created by Ben Honig on 7/31/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//


#import "InAppManager.h"


@interface InAppManager () {
    
    NSMutableArray* purchaseableProducts; // an array of possible products to purchase
    NSUserDefaults* defaults; // store a bool variable marking products that have been unlocked
    bool removeAdsWasPurchased; // YES or NO
    
    InAppObserver* theObserver;
    
}

@end



@implementation InAppManager

static NSString* removeAdsID = @"com.arik.iRonDome.AdRemoval";

static InAppManager* sharedManager = nil;

+(InAppManager*) sharedManager {
    
    if(sharedManager == nil) {
        
        sharedManager = [[InAppManager alloc] init];
        
    }
    
    return sharedManager;
}

-(id) init {
    
    if  ((self = [super init])) {
        
        //do initialization
        
        sharedManager = self;
        defaults = [NSUserDefaults standardUserDefaults]; //use the standard user defaults
        removeAdsWasPurchased = [defaults boolForKey:removeAdsID]; //will be NO by default (on first run)
        
        purchaseableProducts = [[NSMutableArray alloc] init];
        [self requestProductData]; // as soon as we initialize the class, we want to get product info from the store
        
        theObserver = [[InAppObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:theObserver];
    }
    
    return self;
    
}

-(void) requestProductData {
    
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:removeAdsID, nil]]; //ad  more products in the NSSet if you need them
    
    request.delegate = self;
    [request start];
}


-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //add more here later
    
    NSArray* skProducts = response.products; // skProducts array will equal the array that comes back
   // NSLog(@"This is a vague response, but you should get one... %@", skProducts);
    
    if ( [skProducts count] != 0 && [purchaseableProducts count] == 0) {
        
        for (int i = 0; i < [skProducts count]; i++) {
            
            [purchaseableProducts addObject:[skProducts objectAtIndex:i]];
            SKProduct* product = [purchaseableProducts objectAtIndex:i];
            
            NSLog(@"Feature: %@, Cost: %f, ID: %@", [product localizedTitle], [[product price] doubleValue], [product productIdentifier] );
            
        }
        
    }
    NSLog(@" We found %lu In-App Purchases in iTunes Connect", (unsigned long)[purchaseableProducts count]);
    
}


-(void) failedTransaction:(SKPaymentTransaction*) transaction{
    
    NSString* failMessage = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]  ];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:failMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
}
-(void) provideContent:(NSString*) productIdentifier{
    
    
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter]; // used below to post notifications
    NSString* theMessageForAlert;
    
    if ( [productIdentifier isEqualToString:removeAdsID]) {
        theMessageForAlert = @"You have successfully removed ads!";
        removeAdsWasPurchased = YES;
        [defaults setBool:YES forKey:removeAdsID];
        [notification postNotificationName:@"feature1Purchased" object:nil];
        
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:theMessageForAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}


-(void) buyRemoveAds{
    
    [self buyFeature:removeAdsID];
    
}

-(void) buyFeature:(NSString*) featureID {
    
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"Can make payments");
        SKProduct* selectedProduct;
        
        for (int i=0; i < [purchaseableProducts count]; i++) {
            selectedProduct = [purchaseableProducts objectAtIndex:i];
            
            if ([[selectedProduct productIdentifier] isEqualToString:featureID ]) {
                
                // if we found a SKProduct in the purchaseableProducts array with the same ID as the one we want to buy, we proceed by putting it in the payment queue.
                
                SKPayment* payment = [SKPayment paymentWithProduct:selectedProduct];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                break;
                
            }
            
        }
    
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no" message:@"You can't purchase from the App Store" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(bool) isRemoveAdsPurchasedAlready {
    
    return removeAdsWasPurchased;
}

-(void) restoreCompletedTransactions{
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}



@end
