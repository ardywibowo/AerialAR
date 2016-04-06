//
//  CalculationKit.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <math.h>

//#import <ImageIO/ImageIO.h>

//#import <MediaPlayer/MediaPlayer.h>
//#import <AVFoundation/AVFoundation.h>

#import "DataManager.h"

#import "PointOfInterest.h"
#import "MathPoint.h"
#import "MathVector.h"
#import "MathPlane.h"

#pragma mark - Public Declarations
@interface CalculationKit : NSObject

#pragma mark - Data
@property (readonly) DataManager * dataManager;

#pragma mark - Selection Properties
@property (readonly) double selectionCenterLatitude;
@property (readonly) double selectionCenterLongitude;
@property (readonly) double selectionRadiusMinimum;
@property (readonly) double selectionRadiusMaximum;

#pragma mark - Utility Methods
- (void) rotateToCameraCoordinateSystemPoint:(MathPoint *)point;
- (void) rotateToCameraCoordinateSystemPlane:(MathPlane *)plane;

- (void) rotateToNormalCoordinateSystemPoint:(MathPoint *)point;
- (void) rotateToNormalCoordinateSystemPlane:(MathPlane *)plane;

#pragma mark - Initializer and Setter Methods
- (instancetype) initWithDataManager:(DataManager *)dM;

#pragma mark - POI Methods
- (void) calculateScreenRatioOfPOIs;
- (NSArray * /* of PointOfInterest */) getCopyOfVisiblePoints;

#pragma mark - Selection Methods
- (void) calculateRadiusesOfSelectionPointsForSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios;
- (void) calculateGPSOfSelectionCenter;
@end