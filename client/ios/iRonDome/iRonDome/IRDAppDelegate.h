//
//  IRDAppDelegate.h
//  iRonDome
//
//  Created by Arik Sosman on 7/16/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IRDAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
