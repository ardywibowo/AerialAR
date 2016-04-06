//
//  CalculationUtilities.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/16/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "CalculationUtilities.h"

@implementation CalculationUtilities

#pragma mark - Constants
static const double FEET_PER_LATITUDE = 364636.8;
static const double FEET_PER_MILE = 5280.0;
static const double METER_PER_FOOT = 0.3048;
static const double MILES_PER_DEGREE = 69.172;

#pragma mark - Utility Methods
+ (double) feetToMeters:(double)feet
{
    return feet * METER_PER_FOOT;
}

+ (double) radiansToDegrees:(double)radians
{
    double degrees = radians * 180.0/M_PI;
    return degrees;
}

+ (double) degreesToRadians:(double)degrees
{
    double radians = degrees * M_PI/180.0;
    return radians;
}

+ (double) latitudeToFeet:(double)latitude
{
    double feet = latitude * FEET_PER_LATITUDE; //This is the feet/latitude constant
    return feet;
}

+ (double) feetToLatitude:(double)feet
{
    double latitude = feet/FEET_PER_LATITUDE;
    return latitude;
}

+ (double) longitudeToFeet:(double)longitude atLatitude:(double)latitude
{
    double feetPerDegreeLongitude = MILES_PER_DEGREE * FEET_PER_MILE * cos([CalculationUtilities degreesToRadians:latitude]);
    double feet = longitude * feetPerDegreeLongitude;
    return feet;
}

+ (double) feetToLongitude:(double)feet atLatitude:(double)latitude
{
    double longitudePerFeet = 1/(MILES_PER_DEGREE * FEET_PER_MILE * cos([CalculationUtilities degreesToRadians:latitude]));
    double longitude = feet * longitudePerFeet;
    return longitude;
}

+ (double) distanceFromLatitude:(double)latitude andLongitude:(double)longitude
                toOtherLatitude:(double)otherLatitude andOtherLongitude:(double)otherLongitude
{
    double firstLatitudeFeet = [CalculationUtilities latitudeToFeet:latitude];
    double firstLongitudeFeet = [CalculationUtilities longitudeToFeet:longitude atLatitude:latitude];
    
    MathPoint * point = [[MathPoint alloc] initWithX:firstLongitudeFeet andY:firstLatitudeFeet];
    
    double secondLatitudeFeet= [CalculationUtilities latitudeToFeet:otherLatitude];
    double secondLongitudeFeet =[CalculationUtilities longitudeToFeet:otherLongitude atLatitude:otherLatitude];
    
    MathPoint * otherPoint = [[MathPoint alloc] initWithX:secondLongitudeFeet andY:secondLatitudeFeet];
    
    return [point distanceToPoint:otherPoint];
}

+ (BOOL) POI:(PointOfInterest *)p existsInArray:(NSArray *)POIArray
{
    for (PointOfInterest * existingPOI in POIArray)
        if ([p equalsPOI:existingPOI]) {
            return YES;
        }
    return NO;
}

//AIzaSyDQM4-dDWzWIOk2YsIqJK6OzymxMllroeI
//AIzaSyBoWvPmAMLzlpQJn3B1XpVzcBXebFiEGRE


@end
