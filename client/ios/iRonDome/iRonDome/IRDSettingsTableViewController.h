//
//  IRDSettingsTableViewController.h
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface IRDSettingsTableViewController : UITableViewController <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *banner;


@end
