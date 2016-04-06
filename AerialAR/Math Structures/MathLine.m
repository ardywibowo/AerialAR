//
//  MathLine.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/14/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "MathLine.h"

@implementation MathLine

- (instancetype) initWithOriginPoint:(MathPoint *)o andTangentVector:(MathVector *)t
{
    self = [super init];
    if (self) {
        self.origin = o;
        self.tangent = t;
    }
    return self;
}

- (double) distanceToPoint:(MathPoint *)point
{
    MathVector * originToPoint = [[MathVector alloc] initWithPointA:self.origin andB:point];
    MathVector * crossProductWithTangent = [originToPoint getCrossProductWithVector:self.tangent];
    
    double crossProductMagnitude = fabs([crossProductWithTangent getMagnitude]);
    double tangentVectorMagnitude = fabs([self.tangent getMagnitude]);
    
    double distance = crossProductMagnitude/tangentVectorMagnitude;
    
    return distance;
}

@end
