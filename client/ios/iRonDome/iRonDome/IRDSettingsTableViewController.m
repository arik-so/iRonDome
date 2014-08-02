//
//  IRDSettingsTableViewController.m
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDSettingsTableViewController.h"
#define kAvenirLight @"Avenir-Light"

#import <Parse/Parse.h>
#import "Flurry/Flurry.h"
#import "FlurryAds.h"

@interface IRDSettingsTableViewController ()

@property (strong, nonatomic) NSArray *developers;

@property (strong, nonatomic) UISwitch *muteSwitch;
@property (strong, nonatomic) UISwitch *notificationSwitch;

@property (strong, nonatomic) UIView *flurryContainer;

@end

@implementation IRDSettingsTableViewController

static NSString * const KEY_MUTE_NOTIFICATIONS = @"muteNotifications";
static NSString * const KEY_DISABLE_NOTIFICATIONS = @"disableNotifications";

static NSString * const AD_SPACE_NAME = @"iRon Dome Ads";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    [Flurry setDebugLogEnabled:YES];
    
    [FlurryAds setAdDelegate:self];
    
    //set this on to see if test ads appear, make sure to turn it off once the test ads appear
    [FlurryAds enableTestAds:YES];  
    
    
    
    
    
    
    self.banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    self.banner.delegate = self;
    [self.banner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    self.tableView.bounces = NO;
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSNumber *defaultMute = [currentInstallation objectForKey:KEY_MUTE_NOTIFICATIONS];
    NSNumber *defaultDisable = [currentInstallation objectForKey:KEY_DISABLE_NOTIFICATIONS];
    
    self.muteSwitch = [[UISwitch alloc] init];
    self.notificationSwitch = [[UISwitch alloc] init];
    
    self.muteSwitch.on = defaultMute.boolValue;
    self.notificationSwitch.on = defaultDisable.boolValue;
    
    [self.muteSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.notificationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.developers = @[
                        @{
                            @"name": @"Arik Sosman",
                            @"function": @"Developer",
                            @"twitter": @"arikaleph"
                            },
                        @{
                            @"name": @"Ben Honig",
                            @"function": @"Developer / Designer",
                            @"twitter": @"iPhonig"
                            }
                        ];
    
    
    int random = arc4random() % 2;
    if(random == 1){
        
        self.developers = @[self.developers[1], self.developers[0]];
        
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.banner.backgroundColor = [UIColor clearColor];
    
    self.flurryContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.tableView.tableFooterView = self.flurryContainer;
    
    [InAppManager sharedManager];
}

- (void)switchValueChanged:(UISwitch *)affectedSwitch{

    BOOL currentlyOn = affectedSwitch.on;
    
    NSNumber *newNumber = @(currentlyOn);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if(affectedSwitch == self.muteSwitch){
        [currentInstallation setObject:newNumber forKey:KEY_MUTE_NOTIFICATIONS];
    }else if(affectedSwitch == self.notificationSwitch){
        [currentInstallation setObject:newNumber forKey:KEY_DISABLE_NOTIFICATIONS];
    }
    
    [currentInstallation saveInBackground];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAds setAdDelegate:self];
    
    [FlurryAds fetchAdForSpace:AD_SPACE_NAME frame:self.flurryContainer.frame size:FULLSCREEN];
    // [FlurryAds fetchAndDisplayAdForSpace:@"iRon Dome Ads" view:self.view size:BANNER_BOTTOM];
    
}




-(void) displayFlurryAd {
    
    if ([FlurryAds adReadyForSpace:AD_SPACE_NAME]) {
        [FlurryAds displayAdForSpace:AD_SPACE_NAME onView:self.flurryContainer];
        
    } else {
        // Fetch an ad
        /* width = self.view.frame.size.width;
        height = self.view.frame.size.height;
        
        currentViewWidth = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))? MAX (width, height) : MIN (width, height);
        
        currentViewHeight = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))? MIN (width, height) : MAX (width, height);
        
        // reconstruct the flurryContainer with the current width, height
        
        [self.flurryContainer setFrame:CGRectMake(0, 0, currentViewWidth, currentViewHeight)]; */
        
        
        [FlurryAds fetchAdForSpace:AD_SPACE_NAME frame:self.flurryContainer.frame size:FULLSCREEN];
    }
    
}


/**
 *  Invoke a takeover at a natural pause in your app. For example, when a
 *  level is completed, an article is read or a button is pressed.
 */
- (IBAction)displayAd:(UIButton *)sender forEvent:(UIEvent *)event {
    
    [self displayFlurryAd];
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [FlurryAds setAdDelegate:nil];
    
    [FlurryAds removeAdFromSpace:@"iRon Dome Ads"];
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [UIView animateWithDuration:0.4 animations:^{
        banner.alpha = 0.0F;
    } completion:^(BOOL finished) {
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    if (!banner.isBannerLoaded) {
        [UIView animateWithDuration:0.4 animations:^{
            banner.alpha = 1.0F;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)spaceDidReceiveAd:(NSString *)adSpace {
    NSLog(@"=========== Ad Space [%@] Did Receive Ad ================ ", adSpace);
    
    [self displayFlurryAd];
    
}

- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error {
    NSLog(@"=========== Ad Space [%@] Did Fail to Receive Ad with error [%@] ================ ", adSpace, error);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)followOnTwitter:(NSString *)twitterName{
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:twitterName]];
        if ([application canOpenURL:url])
        {
            [application openURL:url];
            return;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0){
        return 2;
    }
    
    if (section == 1) {
        return 2;
    }
    
    if (section == 2) {
        return self.developers.count;
    }
    
    return 0;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return  80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *twitterLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *notificationsLabel = (UILabel *)[cell viewWithTag:4];
    
    if(indexPath.section == 0){
        UISwitch *accessorySwitch;
        NSString *titleString;
        
        if(indexPath.row == 0){
            accessorySwitch = self.muteSwitch;
            titleString = NSLocalizedString(@"mute_notifications", nil);
        }else if(indexPath.row == 1){
            accessorySwitch = self.notificationSwitch;
            titleString = NSLocalizedString(@"disable_notifications", nil);
        }
        
        cell.accessoryView = accessorySwitch;
        notificationsLabel.text = titleString;
        
        //hide other labels
        titleLabel.hidden = YES;
        subtitleLabel.hidden = YES;
        twitterLabel.hidden = YES;
        
        return cell;
        
    }
    
    if(indexPath.section == 1){
        NSString *titleString;
        
        if(indexPath.row == 0){
            titleString = NSLocalizedString(@"remove_ads", nil);
        }else if(indexPath.row == 1){
            titleString = NSLocalizedString(@"restore_purchases", nil);
        }
        
        notificationsLabel.text = titleString;
        
        //hide other labels
        titleLabel.hidden = YES;
        subtitleLabel.hidden = YES;
        twitterLabel.hidden = YES;
        
        return cell;
        
    }
    
    if (indexPath.section == 2) {
        
        NSDictionary *devDetails = self.developers[indexPath.row];
        
        titleLabel.text = devDetails[@"name"];
        subtitleLabel.text = devDetails[@"function"];
        twitterLabel.text = [NSString stringWithFormat:@"@%@", devDetails[@"twitter"]];
        
        //hide notifications label
        notificationsLabel.hidden = YES;
        
        return cell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 3) {
        return 120;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return self.banner;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return self.banner.frame.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    if (section == 0) {
        headerView.frame = CGRectMake(0, 0, 320, 20);
        headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1.0];
        UILabel *titleHeader = [[UILabel alloc] init];
        titleHeader.frame = CGRectMake(20, 10, 320, 21);
        titleHeader.font = [UIFont fontWithName:kAvenirLight size:16];
        titleHeader.textAlignment = NSTextAlignmentLeft;
        titleHeader.text = NSLocalizedString(@"notifications", nil);
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    if (section == 1) {
        headerView.frame = CGRectMake(0, 0, 320, 20);
        headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1.0];
        UILabel *titleHeader = [[UILabel alloc] init];
        titleHeader.frame = CGRectMake(20, 10, 320, 21);
        titleHeader.font = [UIFont fontWithName:kAvenirLight size:16];
        titleHeader.textAlignment = NSTextAlignmentLeft;
        titleHeader.text = NSLocalizedString(@"store", nil);
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    if (section == 2) {
        headerView.frame = CGRectMake(0, 0, 320, 20);
        headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1.0];
        UILabel *titleHeader = [[UILabel alloc] init];
        titleHeader.frame = CGRectMake(20, 10, 320, 21);
        titleHeader.font = [UIFont fontWithName:kAvenirLight size:16];
        titleHeader.textAlignment = NSTextAlignmentLeft;
        titleHeader.text = NSLocalizedString(@"credits", nil);
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    if (section == 3) {
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *titleHeader = [[UILabel alloc] init];
        titleHeader.frame = CGRectMake(0, 15, headerView.frame.size.width, 125.0);
        [titleHeader setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        titleHeader.font = [UIFont fontWithName:kAvenirLight size:12];
        titleHeader.textAlignment = NSTextAlignmentCenter;
        titleHeader.numberOfLines = 2;
        NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
        titleHeader.text = [NSString stringWithFormat:@"iRon Dome\nVersion %@", versionString];
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //remove ads
            if ([[InAppManager sharedManager] isRemoveAdsPurchasedAlready]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                                message:@"You have already removed ads!"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            }else{
                [[InAppManager sharedManager] buyRemoveAds];
            }
        }else{
            //restore purchases
            [[InAppManager sharedManager] restoreCompletedTransactions];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section == 2) {
        NSDictionary *devDetails = self.developers[indexPath.row];
        [self followOnTwitter:devDetails[@"twitter"]];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
