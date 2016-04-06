//
//  DrawingRecognizer.m
//  Ellipse
//
//  Created by Randy Ardywibowo on 4/24/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "DrawingRecognizer.h"

@implementation DrawingRecognizer

@synthesize ellipseClosureAngleVariance = ellipseClosureAngleVariance_;
@synthesize ellipseClosureDistanceVariance = ellipseClosureDistanceVariance_;
@synthesize maximumEllipseTime = maximumEllipseTime_;
@synthesize radiusVariancePercent = radiusVariancePercent_;
@synthesize overlapTolerance = overlapTolerance_;
@synthesize minimumNumPoints = minimumNumPoints_;

@synthesize center = center_;
@synthesize radiusX = radiusX_;
@synthesize radiusY = radiusY_;
@synthesize error = error_;

@synthesize ellipseView;

- (instancetype) initWithView:(UIView *) v
{
    if ( (self = [super init]) ) {
        ellipseClosureAngleVariance_ = 45.0;
        ellipseClosureDistanceVariance_ = 50.0;
        maximumEllipseTime_ = 7.5;
        radiusVariancePercent_ = 25.0;
        overlapTolerance_ = 10000000;
        minimumNumPoints_ = 1;
        points_ = [[NSMutableArray alloc] init];
        firstTouch_ = CGPointZero;
        firstTouchTime_ = 0.0;
        center_ = CGPointZero;
        radiusX_ = 0.0;
        radiusY_ = 0.0;
        
        ellipseView = v;
    }
    return self;
}

- (void) failWithError:(RAEllipseGestureError)error
{
#ifdef DEBUG
    NSLog(@"Failed: Ellipse was not detected, code %d", error);
#endif
    error_ = error;
    self.state = UIGestureRecognizerStateFailed;
    if ( [self.delegate conformsToProtocol:@protocol(RAEllipseGestureFailureDelegate)] ) {
        [(id<RAEllipseGestureFailureDelegate>)self.delegate ellipseGestureFailed:self];
    }
}

- (NSArray *) points
{
    NSMutableArray *allPoints = [points_ mutableCopy];
    [allPoints insertObject:NSStringFromCGPoint(firstTouch_) atIndex:0];
    return [NSArray arrayWithArray:allPoints];
}

- (void) reset
{
    [super reset];
    [points_ removeAllObjects];
    firstTouch_ = CGPointZero;
    firstTouchTime_ = 0.0;
    center_ = CGPointZero;
    radiusX_ = 0.0;
    radiusY_ = 0.0;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    firstTouch_ = [[touches anyObject] locationInView:ellipseView];
    firstTouchTime_ = [NSDate timeIntervalSinceReferenceDate];
    
    CGPoint startPoint = [[touches anyObject] locationInView:ellipseView];
    [points_ addObject:NSStringFromCGPoint(startPoint)];
    
    
    self.state = UIGestureRecognizerStateBegan;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint startPoint = [[touches anyObject] locationInView:ellipseView];
    [points_ addObject:NSStringFromCGPoint(startPoint)];    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint endPoint = [[touches anyObject] locationInView:ellipseView];
    [points_ addObject:NSStringFromCGPoint(endPoint)];
    
    // Didn't finish close enough to starting point
    if ( distanceBetweenPoints(firstTouch_, endPoint) > ellipseClosureDistanceVariance_ ) {
        [self failWithError:RAEllipseGestureErrorNotClosed];
        NSLog(@"Error NotClosed");
        return;
    }

    // Took too long to draw
    if ( [NSDate timeIntervalSinceReferenceDate] - firstTouchTime_ > maximumEllipseTime_ ) {
        [self failWithError:RAEllipseGestureErrorTooSlow];
        NSLog(@"Error TooSlow");
        return;
    }

    // Not enough points
    if ( [points_ count] < minimumNumPoints_ ) {
        [self failWithError:RAEllipseGestureErrorTooShort];
        NSLog(@"Error TooShort");
        return;
    }
    
    CGPoint leftMost = firstTouch_;
    NSUInteger leftMostIndex = NSUIntegerMax;
    CGPoint topMost = firstTouch_;
    NSUInteger topMostIndex = NSUIntegerMax;
    CGPoint rightMost = firstTouch_;
    NSUInteger  rightMostIndex = NSUIntegerMax;
    CGPoint bottomMost = firstTouch_;
    NSUInteger bottomMostIndex = NSUIntegerMax;

    // Loop through touches and find out if outer limits of the ellipse
    int index = 0;
    for ( NSString *onePointString in points_ ) {
        CGPoint onePoint = CGPointFromString(onePointString);
        if ( onePoint.x > rightMost.x ) {
            rightMost = onePoint;
            rightMostIndex = index;
        }
        if ( onePoint.x < leftMost.x ) {
            leftMost = onePoint;
            leftMostIndex = index;
        }
        if ( onePoint.y > topMost.y ) {
            topMost = onePoint;
            topMostIndex = index;
        }
        if ( onePoint.y < bottomMost.y ) {
            bottomMost = onePoint;
            bottomMostIndex = index;
        }
        index++;
    }
    
    /*
    // If startPoint is one of the extreme points, take set it
    if ( rightMostIndex == NSUIntegerMax ) {
        rightMost = firstTouch_;
    }
    if ( leftMostIndex == NSUIntegerMax ) {
        leftMost = firstTouch_;
    }
    if ( topMostIndex == NSUIntegerMax ) {
        topMost = firstTouch_;
    }
    if ( bottomMostIndex == NSUIntegerMax ) {
        bottomMost = firstTouch_;
    }
    */
    
    // Figure out the approx middle of the ellipse
    center_ = CGPointMake((rightMost.x + leftMost.x) / 2.0, (topMost.y + bottomMost.y) / 2.0);

    // This check is probably not necessary
    // Make sure they closed the ellipse - the startPoint and endPoint should be within a few degrees of each other.
    //    CGFloat angle = angleBetweenLines(firstTouch, center, endPoint, center);
    //    
    //    if (fabs(angle) > kEllipseClosureAngleVariance ) {
    //        label.text = [NSString stringWithFormat:@"Didn't close ellipse, angle (%f) too large!", fabs(angle)];
    //        [self performSelector:@selector(eraseText) withObject:nil afterDelay:2.0];
    //        return;
    //    }
    
    // Calculate the radius by looking at the first point and the center
    radiusX_ = fabs(distanceBetweenPoints(center_, leftMost));
    radiusY_ = fabs(distanceBetweenPoints(center_, topMost));
    
    CGFloat currentAngle = 0.0; 
    BOOL    hasSwitched = NO;
    
    // Start Ellipse Check=========================================================
    // Make sure all points on ellipse are within a certain percentage of the radius from the center
    // Make sure that the angle switches direction only once. As we go around the ellipse,
    //    the angle between the line from the start point to the end point and the line from  the
    //    current point and the end point should go from 0 up to about 180.0, and then come 
    //    back down to 0 (the function returns the smaller of the angles formed by the lines, so
    //    180° is the highest it will return, 0 the lowest. If it switches direction more than once, 
    //    then it's not a ellipse
    
    CGPoint horizontalPoint = CGPointMake(self.view.frame.size.width, center_.y);
    
    index = 0;
    for ( NSString *onePointString in points_ ) {
        CGPoint onePoint = CGPointFromString(onePointString);
        CGFloat distanceFromRadius = fabs(distanceBetweenPoints(center_, onePoint));

        CGFloat cartesianAngle = angleBetweenLines(center_, horizontalPoint, center_, onePoint) * M_PI/180;
        CGFloat currentRadius = radiusX_*radiusY_/sqrt( pow(radiusY_*cos(cartesianAngle), 2) + pow(radiusX_*sin(cartesianAngle), 2));

        CGFloat minRadius = currentRadius - (currentRadius * radiusVariancePercent_);
        CGFloat maxRadius = currentRadius + (currentRadius * radiusVariancePercent_);
        
        if ( distanceFromRadius < minRadius || distanceFromRadius > maxRadius ) {
            [self failWithError:RAEllipseGestureErrorRadiusVarianceTolerance];
            NSLog(@"Error RadiuesVarianceTolerance");
            return;
        }
        
        CGFloat pointAngle = angleBetweenLines(firstTouch_, center_, onePoint, center_);
//        if ( (pointAngle > currentAngle && hasSwitched) && (index < [points_ count] - overlapTolerance_) ) {
//            [self failWithError:RAEllipseGestureErrorOverlapTolerance];
//            NSLog(@"Error OverlapTolerance");
//            return;
//        }
        if ( pointAngle < currentAngle ) {
            if ( !hasSwitched )
                hasSwitched = YES;
        }
        
        currentAngle = pointAngle;
        index++;
    }
    // End Ellipse Check=========================================================
    
    error_ = RAEllipseGestureErrorNone;
    self.state = UIGestureRecognizerStateEnded;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateFailed;
    [super touchesCancelled:touches withEvent:event];
}

@end

#define degreesToRadian(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / M_PI)

CGFloat distanceBetweenPoints (CGPoint first, CGPoint second) {
	CGFloat deltaX = second.x - first.x;
	CGFloat deltaY = second.y - first.y;
	return sqrt(deltaX*deltaX + deltaY*deltaY );
}

CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
	CGFloat height = second.y - first.y;
	CGFloat width = first.x - second.x;
	CGFloat rads = atan(height/width);
	return radiansToDegrees(rads);
	//degs = degrees(atan((top - bottom)/(right - left)))
}

CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
	
	CGFloat a = line1End.x - line1Start.x;
	CGFloat b = line1End.y - line1Start.y;
	CGFloat c = line2End.x - line2Start.x;
	CGFloat d = line2End.y - line2Start.y;
	
	CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
	
	return radiansToDegrees(rads);
}
