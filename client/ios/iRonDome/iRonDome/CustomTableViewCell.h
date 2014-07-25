//
//  CustomTableViewCell.h
//  iRonDome
//
//  Created by Ben Honig on 7/25/14.
//  Copyright (c) 2014 Arik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sirenLabel;

@end
