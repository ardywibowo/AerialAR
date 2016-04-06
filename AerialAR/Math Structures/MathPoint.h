//
//  MathPoint.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#ifndef AerialAR_MathPoint_h
#define AerialAR_MathPoint_h

@interface MathPoint : NSObject

@property (nonatomic, readonly) double X;
@property (nonatomic, readonly) double Y;
@property (nonatomic, readonly) double Z;

- (instancetype) initWithX:(double)_X andY:(double)_Y;
- (instancetype) initWithX:(double)_X andY:(double)_Y andZ:(double)_Z;

+ (MathPoint *) origin;

- (double) distanceToPoint:(MathPoint *)otherPoint;

- (MathPoint *) midpointWithPoint:(MathPoint *)otherPoint;

- (void) xRotationTransformationWithAngle:(double)angle;
- (void) yRotationTransformationWithAngle:(double)angle;
- (void) zRotationTransformationWithAngle:(double)angle;

@end
#endif