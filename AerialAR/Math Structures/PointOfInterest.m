//
//  PointOfInterest.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "PointOfInterest.h"

@implementation PointOfInterest

@synthesize longitude;
@synthesize latitude;
@synthesize name;
@synthesize placeId;
@synthesize distance;

- (instancetype) initWithLatitude:(double)_latitude atLongitude:(double)_longitude withName:(NSString *)_name andPlaceId:(NSString *)_PlaceID{
    self = [super init];
    if(self){
        latitude = _latitude;
        longitude = _longitude;
        name = _name;
        placeId = _PlaceID;
    }
    return self;
}

- (void) setDistance:(double)d {
    distance = d;
}

- (BOOL) equalsPOI:(PointOfInterest *)otherPOI
{
    BOOL sameLatitude = (self.latitude == otherPOI.latitude);
    BOOL sameLongitude = (self.longitude == otherPOI.longitude);
    return sameLatitude && sameLongitude;
}

-(id) copyWithZone:(NSZone *)zone
{
    PointOfInterest * copiedPOI = [[PointOfInterest alloc] initWithLatitude:self.latitude atLongitude:self.longitude withName:self.name andPlaceId:self.placeId];
    copiedPOI.distance = self.distance;
    copiedPOI.ratioX = self.ratioX;
    copiedPOI.ratioY = self.ratioY;
    
    return copiedPOI;
}

@end