//
//  POIPointView.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 3/19/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "POIPointView.h"

#pragma mark - Implementation
@implementation POIPointView

#pragma mark - Initialization Method
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.opaque = NO;
    self.backgroundColor = nil;
    self.contentMode = UIViewContentModeRedraw;
}

#pragma mark - Drawing Method Implementation

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void) drawRect:(CGRect)rect {
    // Create outer white circle for the point
    UIBezierPath * outerMarker = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [[UIColor whiteColor] setFill];
    [outerMarker fill];
    
    // Create inner red circle for the point
    int innerMarkerLength = self.frame.size.height / 2;
    int innerMarkerOrigin = self.frame.size.height / 4;
    CGRect innerFrame = CGRectMake(innerMarkerOrigin, innerMarkerOrigin, innerMarkerLength, innerMarkerLength);
    
    UIBezierPath * innerMarker = [UIBezierPath bezierPathWithOvalInRect:innerFrame];
    [[UIColor redColor] setFill];
    [innerMarker fill];
}

@end
