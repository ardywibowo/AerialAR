//
//  POIView.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 4/25/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PointOfInterest.h"
#import "POIPointView.h"
#import "DrawingRecognizer.h"

#define kEllipseClosureAngleVariance     45.0
#define kEllipseClosureDistanceVariance  50.0
#define kMaximumEllipseTime              2.0
#define kRadiusVariancePercent          25.0
#define kOverlapTolerance               3

@class POIView;

@protocol POIViewDelegate <NSObject>

- (void) selectionPointRatiosPassed:(NSArray * /* of NSString of CGPoint */)eP;

@end

#pragma mark - Public Declarations
@interface POIView : UIView <RAEllipseGestureFailureDelegate>

@property (nonatomic, weak) id <POIViewDelegate> delegate;

#pragma mark - Update Method
- (void) updatePOIs: (NSArray *) points;

#pragma mark - Animation Method
- (void) animateToPOIs:(NSArray *)nextPOIs withDuration:(double)duration;

#pragma mark - Drawing Area Calculation Method
+ (CGRect) CGRectOfMediaSize:(CGSize)mediaSize FitInViewRect:(CGRect)viewRect;

#pragma mark - Gesture Handlers
- (void) handleGesture:(DrawingRecognizer *)gr;
- (void) ellipseGestureFailed:(DrawingRecognizer *)gr;

#pragma mark - View Erase Methods
- (void) eraseView;
- (void) eraseEllipse;

@end