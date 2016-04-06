//
//  POIView.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 4/25/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "POIView.h"

#pragma mark - Private Declarations
@interface POIView ()

#pragma mark - POI Properties
@property (nonatomic) NSArray * POIs;
@property CGPoint POIPointLocation;
@property CGPoint POILabelLocation;

@property CGPoint nextPOIPointLocation;
@property CGPoint nextPOILabelLocation;

@property (nonatomic) NSMutableArray * selectedPOIs;

#pragma mark - Ellipse Gesture Properties
@property (nonatomic, strong) NSArray * ellipsePoints;  //of NSString of CGPoint
@property CGPoint ellipseCenter;
@property CGPoint ellipseMinimumRadiusPoint;
@property CGPoint ellipseMaximumRadiusPoint;

@property CGFloat ellipseRadiusX;
@property CGFloat ellipseRadiusY;

#pragma mark - Setup & POI Drawing Methods
- (void) setup;
- (void) drawPointsForPOIs:(NSArray *)POIs;
- (void) drawLabelsForPOIs:(NSArray *)POIs;

#pragma mark - POI Point Location Finding Method
- (CGPoint) CGPointOfPOI:(PointOfInterest *) POI;

#pragma mark - POI Point and Label Drawing Methods
- (UIView *) pointWithPOI:(PointOfInterest *) POI;
- (UILabel *) labelWithPOI:(PointOfInterest *) POI;

#pragma mark - Label Modifier Methods
- (int) numberOfInterferingObjectsFrom:(NSArray * /* of PointOfInterest */)list affecting:(PointOfInterest *)thing atRange:(int)first to:(int)last;
- (int) closeUpModifier:(NSArray * /* of PointOfInterest */)list affecting:(PointOfInterest *)thing atRange:(int)first to:(int)last;

#pragma mark - Ellipse Drawing Methods
- (void) drawEllipseRadiusWithContext:(CGContextRef) context;
- (void) drawLineUsingPoints:(NSArray * /* of NSString of CGPoint*/)points withContext:(CGContextRef) context;

#pragma mark - Suitable POI Selection Method
- (void) selectSuitablePOIs;

- (void) passSelectionPointRatios;

@end

#pragma mark - Implementation
@implementation POIView

#pragma mark - POI Properties
@synthesize POIPointLocation;
@synthesize POILabelLocation;
@synthesize nextPOIPointLocation;
@synthesize nextPOILabelLocation;

#pragma mark - Ellipse Properties
@synthesize ellipseCenter;
@synthesize ellipseRadiusX;
@synthesize ellipseRadiusY;

#pragma mark - Lazy Instantiation
- (NSArray *) POIs {
    if (!_POIs) {
        _POIs = [[NSArray alloc] init];
    }
    return _POIs;
}

- (NSArray *) ellipsePoints {
    if (!_ellipsePoints) {
        _ellipsePoints = [[NSArray alloc] init];
    }
    return _ellipsePoints;
}

- (NSMutableArray * /* of PointOfInterest */) selectedPOIs {
    if (!_selectedPOIs) {
        _selectedPOIs = [[NSMutableArray alloc] init];
    }
    return _selectedPOIs;
}

#pragma mark - Drawing Area Calculation Method
//This method is the only way to find the CGRect of an image within a UIImageView
+ (CGRect) CGRectOfMediaSize:(CGSize)mediaSize FitInViewRect:(CGRect)viewRect
{
    CGSize viewSize = viewRect.size;      // Size of UIImageView

    // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit
    CGFloat scaleW = viewSize.width / mediaSize.width;
    CGFloat scaleH = viewSize.height / mediaSize.height;
    CGFloat aspect = fmin(scaleW, scaleH);
    
    CGRect mediaRect= { {0,0} , { mediaSize.width*=aspect, mediaSize.height*=aspect } };

    // Center image
    mediaRect.origin.x = (viewSize.width-mediaRect.size.width)/2;
    mediaRect.origin.y = (viewSize.height-mediaRect.size.height)/2;

    // Add imageView offset
    mediaRect.origin.x += viewRect.origin.x;
    mediaRect.origin.y += viewRect.origin.y;
    
    return mediaRect;
}

#pragma mark - Initialization Methods
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setup];
    
    return self;
}

- (void) awakeFromNib
{
    [self setup];
}

- (void) setup
{
    self.opaque = NO;
    [self setBackgroundColor:[UIColor clearColor]];
    [self setNeedsDisplay];
}

- (void) updatePOIs:(NSArray *)points
{
    self.POIs = points;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( [self.ellipsePoints count] > 1 )
    {
        [self drawLineUsingPoints: self.ellipsePoints withContext:context];
        if ( ellipseRadiusX > 0 && ellipseRadiusY >0 )
        {
            [self passSelectionPointRatios];
            
            [self eraseView];
            [self selectSuitablePOIs];
  
            [self drawPointsForPOIs:self.selectedPOIs];
            [self drawLabelsForPOIs:self.selectedPOIs];
            
            // Reset Suitable POIs
            self.selectedPOIs = [[NSMutableArray alloc] init];
        }
    }
    else
    {
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextAddRect(context, self.bounds);
        CGContextFillPath(context);
    }
}

#pragma mark - Gesture Handlers
- (void) handleGesture:(DrawingRecognizer *)gr
{
    if ( gr.state == UIGestureRecognizerStateEnded ) {
        ellipseCenter = gr.center;
        ellipseRadiusX = gr.radiusX;
        ellipseRadiusY = gr.radiusY;
        [self setNeedsDisplay];
    } else if ( gr.state == UIGestureRecognizerStateChanged ) {
        self.ellipsePoints = gr.points;
        [self setNeedsDisplay];
    } else if ( gr.state == UIGestureRecognizerStateBegan ) {
        self.ellipsePoints = nil;
        ellipseCenter = CGPointZero;
        ellipseRadiusX = -1;
        ellipseRadiusY = -1;
        [self setNeedsDisplay];
    }
}

- (void) ellipseGestureFailed:(DrawingRecognizer *)gr
{
    switch ( gr.error ) {
        case RAEllipseGestureErrorNotClosed:
            NSLog(@"Failed: Didn't finish close enough to starting point");
            break;
        case RAEllipseGestureErrorOverlapTolerance:
            NSLog(@"Failed: Points beyond overlap tolerance");
            break;
        case RAEllipseGestureErrorRadiusVarianceTolerance:
            NSLog(@"Failed: Points outside radius variance tolerance level");
            break;
        case RAEllipseGestureErrorTooShort:
            NSLog(@"Failed: Not enough points");
            break;
        case RAEllipseGestureErrorTooSlow:
            NSLog(@"Failed: Took too long to draw");
            break;
        case RAEllipseGestureErrorNone:
            break;
    }
}

#pragma mark - Ellipse Drawing Methods
- (void) drawEllipseRadiusWithContext:(CGContextRef) context
{
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    
    //Draw Center Point
    CGRect dotRect = CGRectMake(ellipseCenter.x - 2.5/2, ellipseCenter.y - 2.5/2, 2.5, 2.5);
    CGContextAddEllipseInRect(context, dotRect);
    
    //Draw Radiuses
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextMoveToPoint(context, ellipseCenter.x, ellipseCenter.y - ellipseRadiusY);
    CGContextAddLineToPoint(context, ellipseCenter.x, ellipseCenter.y);
    CGContextAddLineToPoint(context, ellipseCenter.x + ellipseRadiusX, ellipseCenter.y);
    CGContextStrokePath(context);
}

- (void) drawLineUsingPoints:(NSArray * /* of NSString of CGPoint*/)points withContext:(CGContextRef) context
{
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    
    // Connect all the points to draw a line
    BOOL first = YES;
    for (NSString *onePointString in self.ellipsePoints) {
        CGPoint nextPoint = CGPointFromString(onePointString);
        if (first) {
            first = NO;
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextMoveToPoint(context, nextPoint.x, nextPoint.y);
        }
        else CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
    }
    CGContextStrokePath(context);
}

#pragma mark - Selection Point Passing Method
- (void) passSelectionPointRatios;
{
    if ([self.delegate respondsToSelector:@selector(selectionPointRatiosPassed:)])
    {
        NSMutableArray * pointRatios = [[NSMutableArray alloc] init];
        for (NSString * pointString in self.ellipsePoints) {
            CGPoint point = CGPointFromString(pointString);
            
            double pointRatioX = point.x / self.frame.size.width;
            double pointRatioY = point.y / self.frame.size.height;
            CGPoint pointRatio = CGPointMake(pointRatioX, pointRatioY);
            NSString * pointRatioString = NSStringFromCGPoint(pointRatio);
            
            [pointRatios addObject:pointRatioString];
        }
        [self.delegate selectionPointRatiosPassed:pointRatios];
    }
}

#pragma mark - View Erase Method
- (void) eraseView
{
    [self eraseEllipse];
    [self erasePOIs];
    [self setNeedsDisplay];
}

- (void) eraseEllipse
{
    self.ellipsePoints = nil;
    [self setNeedsDisplay];
}

- (void) erasePOIs
{
    for (UIView *view in [self subviews])
        [view removeFromSuperview];
    [self setNeedsDisplay];
}

#pragma mark - Suitable POI Selection Method
- (void) selectSuitablePOIs
{
    static const CGFloat RADIUS_THRESHOLD = 5;
    
    //Used to find angle with respect to a horizontal line
    CGPoint horizontalPoint = CGPointMake(self.frame.size.width, ellipseCenter.y);
    
    for(PointOfInterest * POI in self.POIs)
    {
        CGPoint POIPoint = [self CGPointOfPOI:POI];
        CGFloat cartesianAngle = angleBetweenLines(ellipseCenter, horizontalPoint, ellipseCenter, POIPoint) * M_PI/180;
        CGFloat currentRadius = ellipseRadiusX*ellipseRadiusY/sqrt( pow(ellipseRadiusY*cos(cartesianAngle), 2) + pow(ellipseRadiusX*sin(cartesianAngle), 2));
        
        CGFloat xDistance = (POIPoint.x - ellipseCenter.x);
        CGFloat yDistance = (POIPoint.y - ellipseCenter.y);
        CGFloat distance = sqrt( pow(xDistance, 2) + pow(yDistance, 2) );
        
        //Select POIs
        if(distance <= currentRadius + RADIUS_THRESHOLD)
            [self.selectedPOIs addObject:POI];
    }
}

#pragma mark - POI Point Location Finding Method
static const CGFloat POI_POINT_LENGTH = 4;

- (CGPoint) CGPointOfPOI:(PointOfInterest *) POI
{
    CGFloat pointLocationX = [POI ratioX] * self.frame.size.width - POI_POINT_LENGTH/2;
    CGFloat pointLocationY = [POI ratioY] * self.frame.size.height - POI_POINT_LENGTH/2;
    
    CGPoint pointLocation = CGPointMake(pointLocationX, pointLocationY);
    
    return pointLocation;
}

#pragma mark - POI Drawing Methods
- (void) drawPointsForPOIs: (NSArray *) POIs
{
    int i = 0;
    
    for(PointOfInterest * workingPOI in POIs)
    {
        
        POIPointLocation.x = [workingPOI ratioX] * self.frame.size.width;
        POIPointLocation.y = [workingPOI ratioY] * self.frame.size.height;
        
        UIView * POIPoint = [self pointWithPOI:workingPOI];
        POIPoint.tag = 2*i +2;
        
        [self addSubview:POIPoint];
        
        i++;
    }
}

- (UIView *) pointWithPOI:(PointOfInterest *) POI
{
    // -POI_POINT_LENGTH/2 because the origin of the frame is on the top-left
    CGRect pointFrame = CGRectMake(POIPointLocation.x - POI_POINT_LENGTH/2, POIPointLocation.y - POI_POINT_LENGTH/2, POI_POINT_LENGTH, POI_POINT_LENGTH);
    UIView * pointView = [[POIPointView alloc] initWithFrame:pointFrame];
    
    return pointView;
}

- (void) drawLabelsForPOIs: (NSArray *) POIs
{
    int i = 0;
    
    // Draw a label for each POI in array
    for (PointOfInterest * workingPOI in POIs)
    {
        int labelInterferringObjectsModifier = [self numberOfInterferingObjectsFrom:self.POIs affecting:workingPOI atRange:0 to:i];
        int labelCloseUpModifier = [self closeUpModifier:self.POIs affecting:workingPOI atRange:0 to:i];
        int labelDistanceModifier = [workingPOI distance]/2500;
        
        int labelLocationModifierX = 5;
        int labelLocationModifierY = 10 + (self.frame.size.height/100* (labelInterferringObjectsModifier + labelCloseUpModifier) * labelDistanceModifier);
        
        POILabelLocation.x = [workingPOI ratioX] * self.frame.size.width + labelLocationModifierX;
        POILabelLocation.y = [workingPOI ratioY] * self.frame.size.height - labelLocationModifierY;
        
        UIView * POILabel = [self labelWithPOI:workingPOI];
        POILabel.tag = 2*i+1;
        POILabel.accessibilityIdentifier = [workingPOI placeId];
        
        [self addSubview: POILabel];
        i++;
    }
}

- (UILabel *) labelWithPOI:(PointOfInterest *)POI
{
    
    CGRect labelFrame = CGRectMake(POILabelLocation.x, POILabelLocation.y, self.frame.size.width/3, self.frame.size.height/20);
    
    UILabel * POILabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    POILabel.text = [POI name];
    POILabel.font = [UIFont systemFontOfSize: MAX(self.frame.size.width/100, self.frame.size.width*2.5/[POI distance])];
    
    POILabel.textColor = [UIColor colorWithRed:1 green:1 blue:1  alpha:1.0];

    CGSize expectedLabelSize = [POILabel.text
                                boundingRectWithSize:POILabel.frame.size
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{ NSFontAttributeName:POILabel.font }
                                context:nil].size;
    
    POILabel.frame = CGRectMake(POILabelLocation.x, POILabelLocation.y, expectedLabelSize.width, expectedLabelSize.height);
    POILabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.7 alpha:MIN(0.35, 525/[POI distance])];
    
    return POILabel;
}

#pragma mark - Label Modifier Methods
- (int) numberOfInterferingObjectsFrom:(NSArray * /* of PointOfInterest */)list affecting:(PointOfInterest *)thing atRange:(int)first to:(int)last
{
    static const int PHONE_LABEL_HEIGHT = 15;
    static const int TABLET_LABEL_HEIGHT = 25;
    
    static const int PHONE_LABEL_WIDTH = 75;
    static const int TABLET_LABEL_WIDTH = 125;
    
    int drawingHeight = self.frame.size.height;
    int drawingWidth = self.frame.size.width;
    
    int count = 0;
    
    for(int i = first; i < last; i++)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if(ABS([[list objectAtIndex:i] ratioX] - [thing ratioX]) * drawingWidth < PHONE_LABEL_WIDTH && ABS([[list objectAtIndex:i] ratioY] - [thing ratioY]) * drawingHeight < PHONE_LABEL_HEIGHT)
                count++;
        }
        else
        {
            if(ABS([[list objectAtIndex:i] ratioX] - [thing ratioX]) * drawingWidth < TABLET_LABEL_WIDTH && ABS([[list objectAtIndex:i] ratioY] - [thing ratioY]) * drawingHeight < TABLET_LABEL_HEIGHT)
                count++;
        }
    }
    return count;
}
- (int) closeUpModifier:(NSArray * /* of PointOfInterest */)list affecting:(PointOfInterest *)thing atRange:(int)first to:(int)last
{
    int modifier = 0;
    
    int drawingHeight = self.frame.size.height;
    
    for(int i = first; i < last; i++)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if(ABS([[list objectAtIndex:i] ratioY] - [thing ratioY]) * drawingHeight < ([thing ratioY] * drawingHeight - 175) * 1.15)
                modifier+=8;
        }
        else
        {
            if(ABS([[list objectAtIndex:i] ratioY] - [thing ratioY]) * drawingHeight < ([thing ratioY] * drawingHeight - 400) * 1.25)
                modifier+=8;
        }
    }
    return modifier;
}

#pragma mark - Animation Method
- (void) animateToPOIs:(NSArray *)nextPOIs withDuration:(double)duration
{
    //Create transition animation for labels
    for(int i = 0; i < [self subviews].count/2; i++)
    {
        POIPointView * POIPoint = (POIPointView *)[self viewWithTag:2*i +2];
        UILabel * POILabel = (UILabel *)[self viewWithTag:2*i+1];
        
        for(int i = 0; i < nextPOIs.count; i++)
        {
            PointOfInterest * nextPOI = nextPOIs[i];
            
            if([POILabel.accessibilityIdentifier isEqualToString:nextPOI.placeId])
            {
                int labelInterferringObjectsModifier = [self numberOfInterferingObjectsFrom:nextPOIs affecting:nextPOI atRange:0 to:i];
                int labelCloseUpModifier = [self closeUpModifier:nextPOIs affecting:nextPOI atRange:0 to:i];
                int labelDistanceModifier = [nextPOI distance]/2500;
                
                int labelLocationModifierX = 5;
                int labelLocationModifierY = 10 + (self.frame.size.height/100* (labelInterferringObjectsModifier + labelCloseUpModifier) * labelDistanceModifier);
                
                nextPOILabelLocation.x = [nextPOI ratioX] * self.frame.size.width + labelLocationModifierX;
                nextPOILabelLocation.y = [nextPOI ratioY] * self.frame.size.height - labelLocationModifierY;
                
                CGSize expectedLabelSize = [POILabel.text
                                            boundingRectWithSize:POILabel.frame.size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName:POILabel.font }
                                            context:nil].size;
                
                CGRect nextPOILabelFrame = CGRectMake(nextPOILabelLocation.x, nextPOILabelLocation.y, expectedLabelSize.width, expectedLabelSize.height);
                
                nextPOIPointLocation.x = [nextPOI ratioX] * self.frame.size.width;
                nextPOIPointLocation.y = [nextPOI ratioY] * self.frame.size.height;
                
                CGRect nextPOIPointFrame = CGRectMake(nextPOIPointLocation.x - POI_POINT_LENGTH/2, nextPOIPointLocation.y - POI_POINT_LENGTH/2, POI_POINT_LENGTH, POI_POINT_LENGTH);
                
                [UIView animateWithDuration: duration animations:^{
                    POILabel.frame = nextPOILabelFrame;
                    POIPoint.frame = nextPOIPointFrame;
                }];

                break;
            }
        }
    }
}
@end
