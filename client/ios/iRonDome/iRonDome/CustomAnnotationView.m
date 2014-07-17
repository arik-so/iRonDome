//
//  CustomAnnotationView.m
//  Direct Connect
//
//  Created by Ben Honig on 4/18/13.
//  Copyright (c) 2013 iPhonig, LLC. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil){
        CGRect frame = self.frame;
        frame.size = CGSizeMake(60.0, 85.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(-5, -5);
    }
    return self;
}

-(void) drawRect:(CGRect)rect{
    [[UIImage imageNamed:@"rocketPin"] drawInRect:CGRectMake(30, 30.0, 22.0, 36.0)];//makes that image the custom pin
}

@end

