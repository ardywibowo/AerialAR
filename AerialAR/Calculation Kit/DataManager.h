//
//  DataManager.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/15/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "RXMLElement.h"

#import "CalculationUtilities.h"
#import "PointOfInterest.h"

@interface DataManager : NSObject

@property (readonly) int index;

@property (readonly) double cameraLatitude;    // Degrees
@property (readonly) double cameraLongitude;   // Degrees
@property (readonly) double cameraAltitude;    // Feet
@property (readonly) double cameraHeading;     // Radians
@property (readonly) double cameraPitch;       // Radians
@property (readonly) double cameraRoll;        // Radians
@property (readonly) double cameraHFOV;        // Radians
@property (readonly) double cameraVFOV;        // Radians

@property (nonatomic, readonly) NSMutableArray * cachedLatitudes;
@property (nonatomic, readonly) NSMutableArray * cachedLongitudes;

@property (nonatomic, readonly) NSMutableArray * allPOIs; // of PointOfInterest

#pragma mark - Initialization
- (instancetype) initWithXMLName:(NSString *)xN;

#pragma mark - Utility Methods
- (int) XMLDataIndex;

+ (BOOL) fileExistsWithNameAndExtension:(NSString *)nameAndExtension;

#pragma mark - POI Search Request Methods
- (void) requestSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude
                        andSearchRadius:(double)searchRadius;

- (void) requestSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude
                        andSearchRadius:(double)searchRadius andKeywords:(NSArray * /* of NSString */)keywords;

- (void) requestVaryingRadiusSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude
                              andMaximumSearchRadius:(double)maximumSearchRadius;

#pragma mark - Camera Orientation Methods
- (void) setCameraOrientationData;
- (BOOL) cameraOrientationDataExistsForCurrentIndex;
- (void) incrementIndex;
- (void) decrementIndex;

@end
