//
//  DrawingRecognizer.h
//  Ellipse
//
//  Created by Randy Ardywibowo on 4/24/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

CGFloat distanceBetweenPoints (CGPoint first, CGPoint second);
CGFloat angleBetweenPoints(CGPoint first, CGPoint second);
CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint lin2End);

@class DrawingRecognizer;

@protocol RAEllipseGestureFailureDelegate <UIGestureRecognizerDelegate>

- (void) ellipseGestureFailed:(DrawingRecognizer *)gr;

@end

typedef enum RAEllipseGestureError {
    RAEllipseGestureErrorNone,
    RAEllipseGestureErrorNotClosed,
    RAEllipseGestureErrorTooSlow,
    RAEllipseGestureErrorTooShort,
    RAEllipseGestureErrorRadiusVarianceTolerance,
    RAEllipseGestureErrorOverlapTolerance,
} RAEllipseGestureError;

@interface DrawingRecognizer : UIGestureRecognizer
{
    NSMutableArray *points_;
    CGPoint firstTouch_;
    NSTimeInterval firstTouchTime_;
}

- (instancetype) initWithView:(UIView *) v;

@property CGFloat ellipseClosureAngleVariance;
/// Maximum distance allowed between the two end points, in pixels
@property CGFloat ellipseClosureDistanceVariance;
/// Maximum time allowed to complete a Ellipse, in seconds
@property CGFloat maximumEllipseTime;
@property CGFloat radiusVariancePercent;
@property NSInteger overlapTolerance;
/// The minimum number of points that should make up a ellipse
@property NSInteger minimumNumPoints;

@property (readonly) CGPoint center;
@property (readonly) CGFloat radiusX;
@property (readonly) CGFloat radiusY;
@property (readonly) NSArray *points;
@property (readonly) RAEllipseGestureError error;

@property (nonatomic) UIView * ellipseView;

@end
