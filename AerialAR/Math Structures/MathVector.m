//
//  MathVector.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "MathVector.h"

@implementation MathVector

@synthesize A;
@synthesize B;
@synthesize XComponent;
@synthesize YComponent;
@synthesize ZComponent;

- (instancetype) initWithPointA:(MathPoint *)_A andB:(MathPoint *)_B {
    self = [super init];
    if(self)
    {
        A = _A;
        B = _B;
        XComponent = _B.X - _A.X;
        YComponent = _B.Y - _A.Y;
        ZComponent = _B.Z - _A.Z;
    }
    return self;
}

- (instancetype) initWithMagnitude:(double)m andTheta:(double)t andPhi:(double)p
{
    self = [super init];
    if (self) {
        XComponent = m * sinl(p) * cosl(t);
        YComponent = m * sinl(p) * sinl(t);
        ZComponent = m * cosl(p);
        A = [MathPoint origin];
        B = [[MathPoint alloc] initWithX:XComponent andY:YComponent andZ:ZComponent];
    }
    return self;
}

- (instancetype) initWithXComponent:(double)_X andYComponent:(double)_Y andZComponent:(double)_Z
{
    self = [super init];
    if (self) {
        XComponent = _X;
        YComponent = _Y;
        ZComponent = _Z;
        A = [MathPoint origin];
        B = [[MathPoint alloc] initWithX:_X andY:_Y andZ:_Z];
    }
    return self;
}

+ (MathVector *) unitVectorI
{
    MathVector * i = [[MathVector alloc] initWithXComponent:1.0 andYComponent:0.0 andZComponent:0.0];
    return i;
}

+ (MathVector *) unitVectorJ;
{
    MathVector * j = [[MathVector alloc] initWithXComponent:0.0 andYComponent:1.0 andZComponent:0.0];
    return j;
}

+ (MathVector *) unitVectorK;
{
    MathVector * k = [[MathVector alloc] initWithXComponent:0.0 andYComponent:0.0 andZComponent:1.0];
    return k;
}

- (double) getMagnitude
{
    double magnitude = sqrt( pow( XComponent, 2) + pow( YComponent, 2) + pow(ZComponent, 2) );
    return magnitude;
}

- (double) getDotProductWithVector:(MathVector *)otherVector
{
    double xComponent1 = XComponent;
    double yComponent1 = YComponent;
    double zComponent1 = ZComponent;
    double xComponent2 = otherVector.XComponent;
    double yComponent2 = otherVector.YComponent;
    double zComponent2 = otherVector.ZComponent;
    
    //Dot Product : X1*X2 + Y1*Y2 + Z1*Z2
    double dotProduct = xComponent1*xComponent2 + yComponent1*yComponent2 +zComponent1*zComponent2;
    return dotProduct;
}

- (MathVector *) getCrossProductWithVector:(MathVector *)otherVector
{
    double currentX1 = XComponent;
    double currentY1 = YComponent;
    double currentZ1 = ZComponent;
    
    double currentX2 = otherVector.XComponent;
    double currentY2 = otherVector.YComponent;
    double currentZ2 = otherVector.ZComponent;
    
    double crossX = currentY1*currentZ2 - currentZ1*currentY2;
    double crossY = currentZ1*currentX2 - currentX1*currentZ2;
    double crossZ = currentX1*currentY2 - currentY1*currentX2;
    
    return [[MathVector alloc] initWithXComponent:crossX andYComponent:crossY andZComponent:crossZ];
}

- (double) getAngleWithVector: (MathVector *) otherVector {
    //Find the value of the cosine through A . B = |A||B|*cos(theta)
    double cosAngle = [self getDotProductWithVector:otherVector] / ( [self getMagnitude] * [otherVector getMagnitude] );
    double angle = acos(cosAngle);
    
    return angle;
}

- (void) xRotationTransformationWithAngle:(double)angle
{
    double currentY = YComponent;
    double currentZ = ZComponent;
    YComponent = currentY*cos(angle) -currentZ*sin(angle);
    ZComponent = currentY*sin(angle) +currentZ*cos(angle);
}

- (void) yRotationTransformationWithAngle:(double)angle
{
    double currentZ = ZComponent;
    double currentX = XComponent;
    ZComponent = currentZ*cos(angle) -currentX*sin(angle);
    XComponent = currentZ*sin(angle) +currentX*cos(angle);
}

- (void) zRotationTransformationWithAngle:(double)angle
{
    double currentX = XComponent;
    double currentY = YComponent;
    XComponent = currentX*cos(angle) -currentY*sin(angle);
    YComponent = currentX*sin(angle) +currentY*cos(angle);
}

@end