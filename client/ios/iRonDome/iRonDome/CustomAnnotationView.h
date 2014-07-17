//
//  CustomAnnotationView.h
//  Direct Connect
//
//  Created by Ben Honig on 4/18/13.
//  Copyright (c) 2013 iPhonig, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKAnnotationView{
    
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
