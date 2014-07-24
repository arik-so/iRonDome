//
//  IRDSettingsTableViewController.m
//  iRonDome
//
//  Created by Ben Honig on 7/17/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import "IRDSettingsTableViewController.h"
#define kAvenirLight @"Avenir-Light"

#import "FlurryAds.h"

@interface IRDSettingsTableViewController ()

@property (strong, nonatomic) NSArray *developers;

@end

@implementation IRDSettingsTableViewController

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
    
    
    
    self.banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    self.banner.delegate = self;
    [self.banner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    self.tableView.scrollEnabled = NO;
    
    
    
    
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
    
    
    
    
    // [FlurryAds fetchAndDisplayAdForSpace:@"iRon Dome Ads" view:self.view size:BANNER_BOTTOM];
    
    
    
    // CGRect frame = self.banner.frame;
    // frame.origin.y = -frame.size.height;
    // frame.origin.x = 0.0f;
    
    // self.banner.frame = frame;
    
    // return self.banner;
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.banner.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAds setAdDelegate:self];
    
    [FlurryAds fetchAndDisplayAdForSpace:@"iRon Dome Ads" view:self.view size:BANNER_BOTTOM];
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
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
    
    if (indexPath.section == 0) {
        
        NSDictionary *devDetails = self.developers[indexPath.row];
        
        titleLabel.text = devDetails[@"name"];
        subtitleLabel.text = devDetails[@"function"];
        twitterLabel.text = [NSString stringWithFormat:@"@%@", devDetails[@"twitter"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 120;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        
        return self.banner;
        
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        
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
        titleHeader.text = NSLocalizedString(@"credits", nil);
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    if (section == 1) {
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *titleHeader = [[UILabel alloc] init];
        titleHeader.frame = CGRectMake(0, 15, headerView.frame.size.width, 125.0);
        [titleHeader setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        titleHeader.font = [UIFont fontWithName:kAvenirLight size:12];
        titleHeader.textAlignment = NSTextAlignmentCenter;
        titleHeader.numberOfLines = 2;
        titleHeader.text = [NSString stringWithFormat:@"iRon Dome\nVersion 1.0"];
        titleHeader.textColor = [UIColor blackColor];
        [headerView addSubview:titleHeader];
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
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
