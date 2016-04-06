//
//  CalculationKit.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "CalculationKit.h"

#pragma mark - Private Declarations
@interface CalculationKit ()

// -------------
#pragma mark - Data
@property (readwrite) DataManager * dataManager;

// -------------
#pragma mark - Position Properties
@property MathPoint * cameraPoint;
@property MathPoint * shadow;
@property MathPlane * ground;

#pragma mark - Position Setup Methods
- (void) setCameraPosition;
- (void) setGroundPosition;

// -------------
#pragma mark - POI Properties
@property (nonatomic) NSMutableArray * visiblePOIs; // of PointOfInterest

#pragma mark - POI Location Calculation Methods
- (MathPoint *) coordinatePointOfPOI:(PointOfInterest *)POI;

- (double) horizontalAngleOfPOIPoint:(MathPoint *)POIPoint;
- (double) verticalAngleOfPOIPoint:(MathPoint *)POIPoint;

- (PointOfInterest *) visiblePOIWithPOI:(PointOfInterest *)POI withHorizontalAngle:(double)horizontalAngle
                       andVerticalAngle:(double)verticalAngle andDistance:(double)distance;

// -------------
#pragma mark - Selection Properties
@property (nonatomic) NSArray * selectionPointProjections; // of MathPoint
@property MathPoint * selectionCenter;

@property (readwrite) double selectionCenterLatitude;
@property (readwrite) double selectionCenterLongitude;
@property (readwrite) double selectionRadiusMinimum;
@property (readwrite) double selectionRadiusMaximum;

#pragma mark - Selection Validity Methods
- (BOOL) checkValidityOfSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios;
- (BOOL) checkValidityOfSelectionLine:(MathLine *)selectionLine;

#pragma mark - Selection Projection Methods
- (void) projectOntoGroundSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios;
- (MathLine *) projectionLineOfCGPointRatioString:(NSString *)pointRatioString;
- (MathVector *) projectionVectorOfCGPointRatio:(CGPoint)cgPointRatio;

#pragma mark - Selection Calculation Methods
- (void) calculateRadiusesOfValidSelectionPoints;
- (void) calculateGPSOfSelectionCenter;

- (double) latitudeOfPointInCameraCoordinateSystem:(MathPoint *)cameraCoordinatePoint;
- (double) longitudeOfPointInCameraCoordinateSystem:(MathPoint *)cameraCoordinatePoint;

@end

#pragma mark - Implementation
@implementation CalculationKit

@synthesize dataManager;

#pragma mark - Lazy Instantiation
- (NSMutableArray * /* of PointOfInterest */) visiblePOIs {
    if (!_visiblePOIs) {
        _visiblePOIs = [[NSMutableArray alloc] init];
    }
    return _visiblePOIs;
}

- (NSArray * /* of MathPoint */) selectionPointProjections {
    if (!_selectionPointProjections) {
        _selectionPointProjections = [[NSArray alloc] init];
    }
    return _selectionPointProjections;
}

#pragma mark - Initializers
- (instancetype) initWithDataManager:(DataManager *)dM
{
    self = [super init];
    if (self) {
        self.dataManager = dM;
        
        [self setCameraPosition];
        [self setGroundPosition];
    }
    return self;
}

#pragma mark - Utility Methods
- (void) rotateToCameraCoordinateSystemPoint:(MathPoint *)point {
    [point zRotationTransformationWithAngle:dataManager.cameraHeading];
    [point xRotationTransformationWithAngle:M_PI_2 - dataManager.cameraPitch];
    [point yRotationTransformationWithAngle:-dataManager.cameraRoll];
}

- (void) rotateToCameraCoordinateSystemPlane:(MathPlane *)plane {
    [plane zRotationTransformationWithAngle:dataManager.cameraHeading];
    [plane xRotationTransformationWithAngle:M_PI_2 - dataManager.cameraPitch];
    [plane yRotationTransformationWithAngle:-dataManager.cameraRoll];
}

- (void) rotateToNormalCoordinateSystemPoint:(MathPoint *)point {
    [point yRotationTransformationWithAngle:dataManager.cameraRoll];
    [point xRotationTransformationWithAngle:dataManager.cameraPitch-M_PI_2];
    [point zRotationTransformationWithAngle:-dataManager.cameraHeading];
}

- (void) rotateToNormalCoordinateSystemPlane:(MathPlane *)plane {
    [plane yRotationTransformationWithAngle:dataManager.cameraRoll];
    [plane xRotationTransformationWithAngle:dataManager.cameraPitch-M_PI_2];
    [plane zRotationTransformationWithAngle:-dataManager.cameraHeading];
}

#pragma mark - Position Setup Methods
- (void) setCameraPosition
{
    self.cameraPoint = [MathPoint origin];
    self.shadow = [[MathPoint alloc] initWithX:0.0
                                          andY:0.0
                                          andZ:-dataManager.cameraAltitude];
    [self rotateToCameraCoordinateSystemPoint:self.shadow];
}

- (void) setGroundPosition
{
    MathPoint* groundPoint = [[MathPoint alloc] initWithX:0 andY:0 andZ:-dataManager.cameraAltitude];
    self.ground = [[MathPlane alloc] initWithPoint:groundPoint andNormalVector:[MathVector unitVectorK]];
    [self rotateToCameraCoordinateSystemPlane:self.ground];
}

#pragma mark - POI Location Calculation Methods
- (void) calculateScreenRatioOfPOIs
{
    [self setCameraPosition];
    self.visiblePOIs = [[NSMutableArray alloc] init];
    for (PointOfInterest * POI in dataManager.allPOIs) {
        MathPoint * POIPoint = [self coordinatePointOfPOI:POI];
        
        double horizontalAngle = [self horizontalAngleOfPOIPoint:POIPoint];
        double verticalAngle = [self verticalAngleOfPOIPoint:POIPoint];
        
        MathVector * shadowToPOI = [[MathVector alloc] initWithPointA:self.shadow andB:POIPoint];
        double distanceToPOI = [CalculationUtilities feetToMeters:[shadowToPOI getMagnitude]];
        
        BOOL POIIsInView = (verticalAngle <= dataManager.cameraVFOV/2.0) && (horizontalAngle <= dataManager.cameraHFOV/2.0);
        if (POIIsInView) {
            PointOfInterest * visiblePOI = [self visiblePOIWithPOI:POI withHorizontalAngle:horizontalAngle andVerticalAngle:verticalAngle andDistance:distanceToPOI];
            if(![CalculationUtilities POI:visiblePOI existsInArray:self.visiblePOIs])
                [self.visiblePOIs addObject:visiblePOI];
        }
    }
}

- (NSArray * /* of PointOfInterest */) getCopyOfVisiblePoints
{
    NSArray * visiblePOIsCopy = [[NSMutableArray alloc] initWithArray:self.visiblePOIs copyItems:YES];
    return visiblePOIsCopy;
}

- (MathPoint *) coordinatePointOfPOI:(PointOfInterest *)POI
{
    double CameraToPOILongitudeDifference = POI.longitude - dataManager.cameraLongitude;
    double CameraToPOILatitudeDifference = POI.latitude - dataManager.cameraLatitude;
    
    double xPOI = [CalculationUtilities longitudeToFeet:CameraToPOILongitudeDifference atLatitude:dataManager.cameraLatitude];
    double yPOI = [CalculationUtilities latitudeToFeet:CameraToPOILatitudeDifference];
    
    MathPoint * POIPoint = [[MathPoint alloc] initWithX:xPOI andY:yPOI andZ:-dataManager.cameraAltitude];
    [self rotateToCameraCoordinateSystemPoint:POIPoint];
    
    return POIPoint;
}

- (double) horizontalAngleOfPOIPoint:(MathPoint *)POIPoint
{
    MathPoint * XYProjectionOfPOIPoint = [[MathPoint alloc] initWithX:POIPoint.X andY:POIPoint.Y andZ:0.0];
    MathVector * cameraToXYProjection = [[MathVector alloc] initWithPointA:self.cameraPoint andB:XYProjectionOfPOIPoint];
    
    double horizontalAngle;
    MathVector * crossHorizontal = [[MathVector unitVectorJ] getCrossProductWithVector:cameraToXYProjection];
    if (crossHorizontal.ZComponent < 0) {
        horizontalAngle = [[MathVector unitVectorJ] getAngleWithVector:cameraToXYProjection];
    }
    else horizontalAngle = -[[MathVector unitVectorJ] getAngleWithVector:cameraToXYProjection];
    
    return horizontalAngle;
}

- (double) verticalAngleOfPOIPoint:(MathPoint *)POIPoint
{
    MathPoint * YZProjectionOfPOIPoint = [[MathPoint alloc] initWithX:0.0 andY:POIPoint.Y andZ:POIPoint.Z];
    
    MathVector * cameraToYZProjection = [[MathVector alloc] initWithPointA:self.cameraPoint andB:YZProjectionOfPOIPoint];
    
    double verticalAngle;
    MathVector * crossVertical = [[MathVector unitVectorJ] getCrossProductWithVector:cameraToYZProjection];
    if (crossVertical.XComponent < 0) {
        verticalAngle = [[MathVector unitVectorJ] getAngleWithVector:cameraToYZProjection];
    }
    else verticalAngle = -[[MathVector unitVectorJ] getAngleWithVector:cameraToYZProjection];
    
    return verticalAngle;
}

- (PointOfInterest *) visiblePOIWithPOI:(PointOfInterest *)POI withHorizontalAngle:(double)horizontalAngle
                       andVerticalAngle:(double)verticalAngle andDistance:(double)distance
{
    PointOfInterest * visiblePOI = [[PointOfInterest alloc] initWithLatitude:POI.latitude atLongitude:POI.longitude withName:POI.name andPlaceId:POI.placeId];

    visiblePOI.ratioX = ( 1+tan(horizontalAngle)/tan(dataManager.cameraHFOV/2.0) )/2.0;
    visiblePOI.ratioY = ( 1+tan(verticalAngle)/tan(dataManager.cameraVFOV/2.0) )/2.0;
    visiblePOI.distance = distance;
    
    return visiblePOI;
}

#pragma mark - Selection Methods
- (void) calculateRadiusesOfSelectionPointsForSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios
{
    [self setGroundPosition];
    if ([self checkValidityOfSelectionPointRatios:selectionPointRatios]) {
        [self projectOntoGroundSelectionPointRatios:selectionPointRatios];
        [self calculateRadiusesOfValidSelectionPoints];
    }
    else {
        self.selectionRadiusMaximum = -1;
        self.selectionRadiusMinimum = -1;
        self.selectionCenter = nil;
    }
}

#pragma mark - Selection Validity Methods
- (BOOL) checkValidityOfSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios
{
    for (NSString * pointRatioString in selectionPointRatios) {
        MathLine * projectionLine = [self projectionLineOfCGPointRatioString:pointRatioString];
        if ([self checkValidityOfSelectionLine:projectionLine] == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) checkValidityOfSelectionLine:(MathLine *)selectionLine
{
    BOOL lineIntersectsInOppositeDirection = ([self.ground parameterOfIntersectionWithLine:selectionLine] < 0);
    BOOL lineIsTangentToGround = ([selectionLine.tangent getAngleWithVector:self.ground.normalVector] == M_PI_2);
    
    if (lineIntersectsInOppositeDirection |  lineIsTangentToGround) return NO;
    else return YES;
}

#pragma mark - Projection Methods
- (void) projectOntoGroundSelectionPointRatios:(NSArray * /* of NSString of CGPoint */)selectionPointRatios
{
    self.selectionPointProjections = [[NSArray alloc] init];
    
    NSMutableArray * mutableSelectionProjections = [[NSMutableArray alloc] init];
    
    for (NSString * pointRatioString in selectionPointRatios) {
        //!!
        MathLine * projectionLine = [self projectionLineOfCGPointRatioString:pointRatioString];
        MathPoint * selectionPointProjection = [self.ground pointOfIntersectionWithLine:projectionLine];
        
        [mutableSelectionProjections addObject:selectionPointProjection];
    }
    self.selectionPointProjections = mutableSelectionProjections;
}

- (MathLine *) projectionLineOfCGPointRatioString:(NSString *)pointRatioString
{
    CGPoint selectionPointRatio = CGPointFromString(pointRatioString);
    MathVector * projectionVector = [self projectionVectorOfCGPointRatio:selectionPointRatio];
    MathLine * projectionLine = [[MathLine alloc] initWithOriginPoint:[MathPoint origin] andTangentVector:projectionVector];
    
    return projectionLine;
}

- (MathVector *) projectionVectorOfCGPointRatio:(CGPoint)cgPointRatio
{
    double horizontalOffsetAngle = atan2l( (cgPointRatio.x - 1.0/2.0)*tan(dataManager.cameraHFOV/2.0), 1.0/2.0);
    double verticalOffsetAngle = atan2l((1.0/2.0 - cgPointRatio.y)*tan(dataManager.cameraVFOV/2.0), 1.0/2.0);
    
    double xComponent = tan(horizontalOffsetAngle);
    double zComponent = tan(verticalOffsetAngle);
    double yComponent = 1.0;
    
    return [[MathVector alloc] initWithXComponent:xComponent andYComponent:yComponent andZComponent:zComponent];
}

#pragma mark - Selection Calculation Methods
- (void) calculateRadiusesOfValidSelectionPoints
{
    double maximumRadius;
    MathVector * maximumRadiusVector;
    MathPoint * currentSelectionCenter;
    
    // Combine 2 projection points and find the largest distance
    for (int i = 0; i < self.selectionPointProjections.count; i++)
        if (self.selectionPointProjections.count > 1)
            for (int j = i+1; j < self.selectionPointProjections.count; j++) {
                MathPoint * projection1 = self.selectionPointProjections[i];
                MathPoint * projection2 = self.selectionPointProjections[j];
                
                double currentRadius = [projection1 distanceToPoint:projection2]/2.0;
                if (currentRadius > maximumRadius) {
                    maximumRadius = currentRadius;
                    maximumRadiusVector = [[MathVector alloc] initWithPointA:projection1 andB:projection2];
                    currentSelectionCenter = [projection1 midpointWithPoint:projection2];
                }
            }

    MathVector * minimumRadiusVector = [maximumRadiusVector getCrossProductWithVector:[self.ground normalVector]];
    MathLine * minimumRadiusLine = [[MathLine alloc] initWithOriginPoint:currentSelectionCenter andTangentVector:minimumRadiusVector];
    
    MathPoint * minimumPoint;
    double minimumDistanceToRadiusLine = MAXFLOAT;
    for (MathPoint * point in self.selectionPointProjections) {
        double currentDistanceToRadiusLine = [minimumRadiusLine distanceToPoint:point];
        if (currentDistanceToRadiusLine < minimumDistanceToRadiusLine) {
            minimumDistanceToRadiusLine = currentDistanceToRadiusLine;
            minimumPoint = point;
        }
    }
    double minimumRadius = [minimumPoint distanceToPoint:currentSelectionCenter];
    
    self.selectionRadiusMaximum = maximumRadius;
    self.selectionRadiusMinimum = minimumRadius;
    self.selectionCenter = currentSelectionCenter;
}

// Save radius points to draw
- (void) calculateGPSOfSelectionCenter
{
    MathPoint * selectionCenter = [[MathPoint alloc] initWithX:self.selectionCenter.X andY:self.selectionCenter.Y andZ:self.selectionCenter.Z];
 
    self.selectionCenterLatitude = [self latitudeOfPointInCameraCoordinateSystem:selectionCenter];
    self.selectionCenterLongitude = [self longitudeOfPointInCameraCoordinateSystem:selectionCenter];
}

- (double) latitudeOfPointInCameraCoordinateSystem:(MathPoint *)cameraCoordinatePoint
{
    MathPoint * convertedPoint = [[MathPoint alloc] initWithX:cameraCoordinatePoint.X andY:cameraCoordinatePoint.Y andZ:cameraCoordinatePoint.Z];
    [self rotateToNormalCoordinateSystemPoint:convertedPoint];
    
    double pointLatitude = dataManager.cameraLatitude + [CalculationUtilities feetToLatitude:convertedPoint.Y];
    return pointLatitude;
}

- (double) longitudeOfPointInCameraCoordinateSystem:(MathPoint *)cameraCoordinatePoint
{
    MathPoint * convertedPoint = [[MathPoint alloc] initWithX:cameraCoordinatePoint.X andY:cameraCoordinatePoint.Y andZ:cameraCoordinatePoint.Z];
    [self rotateToNormalCoordinateSystemPoint:convertedPoint];
    
    double pointLongitude = dataManager.cameraLongitude + [CalculationUtilities feetToLongitude:convertedPoint.X atLatitude:dataManager.cameraLatitude];
    return pointLongitude;
}

@end