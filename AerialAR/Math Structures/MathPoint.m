//
//  MathPoint.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "MathPoint.h"

@implementation MathPoint

@synthesize X;
@synthesize Y;
@synthesize Z;

- (instancetype) initWithX:(double)_X andY:(double)_Y {
    self = [super init];
    if(self)
    {
        X = _X;
        Y = _Y;
        Z = 0.0;
    }
    return self;
}

- (instancetype) initWithX:(double)_X andY:(double)_Y andZ:(double)_Z
{
    self = [super init];
    if(self)
    {
        X = _X;
        Y = _Y;
        Z = _Z;
    }
    return self;
}

+ (MathPoint *) origin
{
    return [[MathPoint alloc] initWithX:0.0 andY:0.0 andZ:0.0];
}

- (double) distanceToPoint:(MathPoint *)otherPoint
{
    double xDifference = otherPoint.X - self.X;
    double yDifference = otherPoint.Y - self.Y;
    double zDifference = otherPoint.Z - self.Z;
    
    double distance = sqrt(pow(xDifference, 2) + pow(yDifference, 2) + pow(zDifference, 2));
    return distance;
}

- (MathPoint *) midpointWithPoint:(MathPoint *)otherPoint
{
    double xMidpoint = (self.X + otherPoint.X)/2.0;
    double yMidpoint = (self.Y + otherPoint.Y)/2.0;
    double zMidpoint = (self.Z + otherPoint.Z)/2.0;
    
    return [[MathPoint alloc] initWithX:xMidpoint andY:yMidpoint andZ:zMidpoint];
}

- (void) xRotationTransformationWithAngle:(double)angle
{
    double currentY = Y;
    double currentZ = Z;
    Y = currentY*cos(angle) -currentZ*sin(angle);
    Z = currentY*sin(angle) +currentZ*cos(angle);
}

- (void) yRotationTransformationWithAngle:(double)angle
{
    double currentZ = Z;
    double currentX = X;
    Z = currentZ*cos(angle) -currentX*sin(angle);
    X = currentZ*sin(angle) +currentX*cos(angle);
}

- (void) zRotationTransformationWithAngle:(double)angle
{
    double currentX = X;
    double currentY = Y;
    X = currentX*cos(angle) -currentY*sin(angle);
    Y = currentX*sin(angle) +currentY*cos(angle);
}

@end