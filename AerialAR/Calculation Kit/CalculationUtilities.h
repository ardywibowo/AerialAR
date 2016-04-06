//
//  CalculationUtilities.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/16/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointOfInterest.h"

@interface CalculationUtilities : NSObject

+ (double) feetToMeters:(double)feet;

+ (double) radiansToDegrees:(double)radians;
+ (double) degreesToRadians:(double)degrees;

+ (double) latitudeToFeet:(double)latitude;
+ (double) feetToLatitude:(double)feet;

+ (double) longitudeToFeet:(double)longitude atLatitude:(double)latitude;
+ (double) feetToLongitude:(double)feet atLatitude:(double)latitude;

+ (double) distanceFromLatitude:(double)latitude andLongitude:(double)longitude
                toOtherLatitude:(double)otherLatitude andOtherLongitude:(double)otherLongitude;

+ (BOOL) POI:(PointOfInterest *)p existsInArray:(NSArray *)POIArray;

@end
