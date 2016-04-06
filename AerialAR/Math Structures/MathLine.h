//
//  MathLine.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/14/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MathPoint.h"
#import "MathVector.h"

@interface MathLine : NSObject

@property MathPoint * origin;
@property MathVector * tangent;

- (instancetype) initWithOriginPoint:(MathPoint *)o andTangentVector:(MathVector *)t;

- (double) distanceToPoint:(MathPoint *)point;

@end
