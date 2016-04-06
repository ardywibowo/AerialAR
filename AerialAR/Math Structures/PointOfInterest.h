//
//  PointOfInterest.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#ifndef AerialAR_PointOfInterest_h
#define AerialAR_PointOfInterest_h

#import "MathPoint.h"

@interface PointOfInterest : NSObject <NSCopying>

@property (nonatomic, readonly) double longitude;   // Degrees
@property (nonatomic, readonly) double latitude;    // Degrees
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSString * placeId;

@property (nonatomic) double distance;  // Meters
@property (nonatomic) BOOL isVisible;

@property (nonatomic) double ratioX;
@property (nonatomic) double ratioY;

- (instancetype) initWithLatitude:(double)latitude atLongitude:(double)longitude withName:(NSString *)_name andPlaceId:(NSString *)_PlaceID;
- (void) setDistance:(double)d;
- (BOOL) equalsPOI:(PointOfInterest *)otherPOI;

-(id) copyWithZone:(NSZone *)zone;

@end

#endif