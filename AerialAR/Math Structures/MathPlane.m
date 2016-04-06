//
//  MathPlane.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/11/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "MathPlane.h"

@interface MathPlane ()

@property (readwrite) double A;
@property (readwrite) double B;
@property (readwrite) double C;
@property (readwrite) double D;

@end

@implementation MathPlane

@synthesize A;
@synthesize B;
@synthesize C;
@synthesize D;

#pragma mark - Initialization Methods
- (instancetype) initWithA:(double)_A andB:(double)_B andC:(double)_C andD:(double)_D
{
    self = [super init];
    
    if (self) {
        self.A = _A;
        self.B = _B;
        self.C = _C;
        self.D = _D;
    }
    
    return self;
}

- (instancetype) initWithPoint:(MathPoint *)p andNormalVector:(MathVector *)nV
{
    self = [[MathPlane alloc] init];
    [self setPlaneWithPoint:p andNormalVector:nV];
    
    return self;
}

#pragma mark - Setter Methods
- (void) setPlaneWithPoint:(MathPoint *)p andNormalVector:(MathVector *)nV
{
    // Because the dot product of perpendicular vectors is zero, nV.(PX) = 0
    // N . (X - P) = 0
    // N.X = N.P
    // Ax + By + Cz = Ap + Bq + Cr
    // Ax + By + Cz = D
    
    self.A = nV.XComponent;
    self.B = nV.YComponent;
    self.C = nV.ZComponent;
    self.D = nV.XComponent*p.X + nV.YComponent*p.Y + nV.ZComponent*p.Z;
}

#pragma mark - Plane Property Methods
- (MathVector *) normalVector
{
    MathPoint * normalVectorPoint = [[MathPoint alloc] initWithX:self.A andY:self.B andZ:self.C];
    MathVector * normalVector = [[MathVector alloc] initWithPointA:[MathPoint origin] andB:normalVectorPoint];
    
    return normalVector;
}

- (MathPoint *) pointOnPlane
{
    return [self pointOfIntersectionWithVector:[self normalVector]];
}

- (BOOL) isParallelWithVector:(MathVector *)v
{
    if ([[self normalVector] getDotProductWithVector:v] == 0) {
        return YES;
    }
    else return NO;
}

#pragma mark - Intersection and Transformation Methods
- (MathPoint *) pointOfIntersectionWithVector:(MathVector *)vector
{
    // Assuming a vector: v = <X, Y, Z>,
    // a line tangent to v can be parameterized as : l = <X*t, Y*t, Z*t>.
    // The plane is expressed as    : Ax + By + Cz = D
    // substituting X, Y, and Z from the line we get:
    // AX*t + BY*t + CZ*t = D
    // We can find t and substitute it into the line parametrization to get the point of intersection
    
    double parameterOfIntersection = self.D/(self.A*vector.XComponent + self.B*vector.YComponent + self.C*vector.ZComponent);
    
    double xIntersection = parameterOfIntersection * vector.XComponent;
    double yIntersection = parameterOfIntersection * vector.YComponent;
    double zIntersection = parameterOfIntersection * vector.ZComponent;
    
    MathPoint * pointOfIntersection = [[MathPoint alloc] initWithX:xIntersection andY:yIntersection andZ:zIntersection];
    
    return pointOfIntersection;
}

- (double) parameterOfIntersectionWithLine:(MathLine *)line
{
    double numeratorOfParameter = self.D - self.A*line.origin.X - self.B*line.origin.Y - self.C*line.origin.Z;
    double denominatorOfParameter = self.A*line.tangent.XComponent + self.B*line.tangent.YComponent + self.C*line.tangent.ZComponent;
    
    double parameterOfIntersection = numeratorOfParameter/denominatorOfParameter;
    
    return parameterOfIntersection;
}

- (MathPoint *) pointOfIntersectionWithLine:(MathLine *)line
{
    double parameterOfIntersection = [self parameterOfIntersectionWithLine:line];
    
    double xIntersection = line.origin.X + parameterOfIntersection*line.tangent.XComponent;
    double yIntersection = line.origin.Y + parameterOfIntersection*line.tangent.YComponent;
    double zIntersection = line.origin.Z + parameterOfIntersection*line.tangent.ZComponent;
    
    MathPoint * pointOfIntersection = [[MathPoint alloc] initWithX:xIntersection andY:yIntersection andZ:zIntersection];
    return pointOfIntersection;
}

- (void) xRotationTransformationWithAngle:(double)angle
{
    MathVector * normalVector = [self normalVector];
    MathPoint * pointOnPlane = [self pointOnPlane];
    
    [normalVector xRotationTransformationWithAngle:angle];
    [pointOnPlane xRotationTransformationWithAngle:angle];
    
    [self setPlaneWithPoint:pointOnPlane andNormalVector:normalVector];
}

- (void) yRotationTransformationWithAngle:(double)angle
{
    MathVector * normalVector = [self normalVector];
    MathPoint * pointOnPlane = [self pointOnPlane];
    
    [normalVector yRotationTransformationWithAngle:angle];
    [pointOnPlane yRotationTransformationWithAngle:angle];
    
    [self setPlaneWithPoint:pointOnPlane andNormalVector:normalVector];
}

- (void) zRotationTransformationWithAngle:(double)angle
{
    MathVector * normalVector = [self normalVector];
    MathPoint * pointOnPlane = [self pointOnPlane];
    
    [normalVector zRotationTransformationWithAngle:angle];
    [pointOnPlane zRotationTransformationWithAngle:angle];

    [self setPlaneWithPoint:pointOnPlane andNormalVector:normalVector];
}

@end
