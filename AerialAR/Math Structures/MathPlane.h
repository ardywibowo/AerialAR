//
//  MathPlane.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/11/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathPoint.h"
#import "MathVector.h"
#import "MathLine.h"

@interface MathPlane : NSObject

@property (nonatomic, readonly) double A;
@property (nonatomic, readonly) double B;
@property (nonatomic, readonly) double C;
@property (nonatomic, readonly) double D;

- (instancetype) initWithA:(double)_A andB:(double)_B andC:(double)_C andD:(double)_D;
- (instancetype) initWithPoint:(MathPoint *)p andNormalVector:(MathVector *)nV;

- (void) setPlaneWithPoint:(MathPoint *)p andNormalVector:(MathVector *)nV;

- (MathVector *) normalVector;
- (MathPoint *) pointOnPlane;
- (BOOL) isParallelWithVector:(MathVector *)v;

- (void) xRotationTransformationWithAngle:(double)angle;
- (void) yRotationTransformationWithAngle:(double)angle;
- (void) zRotationTransformationWithAngle:(double)angle;

- (MathPoint *) pointOfIntersectionWithVector:(MathVector *)vector;

- (double) parameterOfIntersectionWithLine:(MathLine *)line;
- (MathPoint *) pointOfIntersectionWithLine:(MathLine *)line;

@end
