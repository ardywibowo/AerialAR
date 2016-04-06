//
//  MathVector.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MathPoint.h"

@interface MathVector : NSObject

@property (nonatomic, readonly) MathPoint* A;
@property (nonatomic, readonly) MathPoint* B;
@property (nonatomic, readonly) double XComponent;
@property (nonatomic, readonly) double YComponent;
@property (nonatomic, readonly) double ZComponent;

- (instancetype) initWithPointA:(MathPoint *)_A andB:(MathPoint *)_B;
- (instancetype) initWithMagnitude:(double)m andTheta:(double)t andPhi:(double)p;
- (instancetype) initWithXComponent:(double)_X andYComponent:(double)_Y andZComponent:(double)_Z;

+ (MathVector *) unitVectorI;
+ (MathVector *) unitVectorJ;
+ (MathVector *) unitVectorK;

- (double) getMagnitude;
- (double) getDotProductWithVector:(MathVector *)otherVector;
- (MathVector *) getCrossProductWithVector:(MathVector *)otherVector;
- (double) getAngleWithVector:(MathVector *)otherVector;

- (void) xRotationTransformationWithAngle:(double)angle;
- (void) yRotationTransformationWithAngle:(double)angle;
- (void) zRotationTransformationWithAngle:(double)angle;

@end