//
//  DataManager.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 6/15/15.
//  Copyright (c) 2015 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@property NSString * XMLName;
@property (readwrite) int index;

@property (readwrite) double cameraLatitude;    // Degrees
@property (readwrite) double cameraLongitude;   // Degrees
@property (readwrite) double cameraAltitude;    // Feet
@property (readwrite) double cameraHeading;     // Radians
@property (readwrite) double cameraPitch;       // Radians
@property (readwrite) double cameraRoll;        // Radians
@property (readwrite) double cameraHFOV;        // Radians
@property (readwrite) double cameraVFOV;        // Radians

@property (nonatomic, readwrite) NSMutableArray * cachedLatitudes;
@property (nonatomic, readwrite) NSMutableArray * cachedLongitudes;

@property (nonatomic, readwrite) NSMutableArray * allPOIs; // of PointOfInterest

#pragma mark - Camera Orientation Data Request Methods
- (void) setCameraOrientationData;

@end

@implementation DataManager

#pragma mark - Constants
static const double MINIMUM_DISTANCE_DIFFERENCE_FOR_REQUEST = 200.0;

static const int POI_QUOTA = 3000;

static const int SEARCH_RADIUS_INCREMENT = 250;

#pragma mark - Utility Methods
- (int) XMLDataIndex
{
    return self.index + 1;
}

+ (BOOL) fileExistsWithNameAndExtension:(NSString *)nameAndExtension
{
    //Current File Directory
    NSString * mainDirectory = [[NSBundle mainBundle] bundlePath];
    NSString * fileDirectory = [NSString stringWithFormat:@"%@/%@", mainDirectory, nameAndExtension];
    
    NSLog(@"%@",fileDirectory);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileDirectory];
    return fileExists;
}

+ (AFHTTPRequestOperation *) requestOperationWithString:(NSString *)requestString
{
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * requestURL = [NSURL URLWithString:requestString];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    return requestOperation;
}

- (BOOL) searchRequestIsAcceptableAtLatitude:(double)latitude andLongitude:(double)longitude
{
    
    
    for (int i = 0; i < self.cachedLatitudes.count; i++) {
        double currentCachedLatitude = [self.cachedLatitudes[i] doubleValue];
        double currentCachedLongitude = [self.cachedLongitudes[i] doubleValue];
        
        double distanceToCached = [CalculationUtilities distanceFromLatitude:latitude andLongitude:longitude
                                                             toOtherLatitude:currentCachedLatitude andOtherLongitude:currentCachedLongitude];
        if (distanceToCached > MINIMUM_DISTANCE_DIFFERENCE_FOR_REQUEST) {
            NSLog(@"Search Request Accepted");
            [self.cachedLatitudes addObject:[NSNumber numberWithDouble:latitude]];
            [self.cachedLongitudes addObject:[NSNumber numberWithDouble:longitude]];
            return YES;
        }
        else {
            NSLog(@"Search Request Unaccepted");
            return NO;
        }
    }
    return YES;
}

#pragma mark - Lazy Instantiation
- (NSMutableArray *) allPOIs {
    if (!_allPOIs) {
        _allPOIs = [[NSMutableArray alloc] init];
    }
    return  _allPOIs;
}

- (NSMutableArray *) cachedLatitudes {
    if (!_cachedLatitudes) {
        _cachedLatitudes = [[NSMutableArray alloc] init];
    }
    return  _cachedLatitudes;
}

- (NSMutableArray *) cachedLongitudes {
    if (!_cachedLongitudes) {
        _cachedLongitudes = [[NSMutableArray alloc] init];
    }
    return  _cachedLongitudes;
}

#pragma mark - Initializers
- (instancetype) initWithXMLName:(NSString *)xN
{
    self = [super init];
    if (self) {
        self.XMLName = xN;
        self.index = 0;
        
        [self setCameraOrientationData];
    }
    return self;
}

#pragma mark - Camera Orientation Data Decoder
- (void) setCameraOrientationData
{
    NSString * XMLNameWithExtension = [NSString stringWithFormat:@"%@.xml", self.XMLName];
    
    RXMLElement * rootOfXML = [RXMLElement elementFromXMLFile:XMLNameWithExtension];
    NSString * XPath = [NSString stringWithFormat:@"/PLACES/LOC[%i]", self.index+1]; // +1 because in XML, LOC is indexed from 1
    NSArray * XMLChildren = [rootOfXML childrenWithRootXPath:XPath];
    
    BOOL dataExists = XMLChildren.count;
    if (dataExists) {
        for(RXMLElement * x in XMLChildren)
        {
            self.cameraLatitude    = [[x child:@"latitude"].text doubleValue];
            self.cameraLongitude   = [[x child:@"longitude"].text doubleValue];
            self.cameraAltitude    = [[x child:@"altitude"].text doubleValue];
            self.cameraHeading     = [CalculationUtilities degreesToRadians: [[x child:@"heading"].text doubleValue] ];
            self.cameraPitch       = [CalculationUtilities degreesToRadians: [[x child:@"pitch"].text doubleValue] ];
            self.cameraRoll        = [CalculationUtilities degreesToRadians: [[x child:@"roll"].text doubleValue] ];
            self.cameraHFOV        = [CalculationUtilities degreesToRadians: [[x child:@"hfov"].text doubleValue] ];
            self.cameraVFOV        = [CalculationUtilities degreesToRadians: [[x child:@"vfov"].text doubleValue] ];
        }
    }
    else NSLog(@"Telemetry Values Do Not Exist");
}

- (void) setCameraOrientationDataForIndex:(int)i
{
    self.index = i;
    [self setCameraOrientationData];
}

- (BOOL) cameraOrientationDataExistsForCurrentIndex
{
    NSString * XMLNameWithExtension = [NSString stringWithFormat:@"%@.xml", self.XMLName];
    
    RXMLElement * rootOfXML = [RXMLElement elementFromXMLFile:XMLNameWithExtension];
    NSString * XPath = [NSString stringWithFormat:@"/PLACES/LOC[%i]", self.index+1]; // +1 because in XML, LOC is indexed from 1
    NSArray * XMLChildren = [rootOfXML childrenWithRootXPath:XPath];
    
    BOOL dataExists = XMLChildren.count;
    return dataExists;
}

- (void) incrementIndex
{
    self.index++;
    [self setCameraOrientationData];
}

- (void) decrementIndex
{
    self.index--;
    [self setCameraOrientationData];
}

#pragma mark - Request Methods
- (void) requestSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude
                        andSearchRadius:(double)searchRadius
{
    if ([self searchRequestIsAcceptableAtLatitude:latitude andLongitude:longitude]) {
        NSString * requestString = [NSString stringWithFormat:
                                    @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%f&type=establishment&key=AIzaSyDQM4-dDWzWIOk2YsIqJK6OzymxMllroeI",
                                    latitude, longitude, searchRadius];
        requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        AFHTTPRequestOperationManager * requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handlePOISearchSuccess:operation];
            [self didFinishPOISearchRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handlePOISearchFailed:operation];
            [self didFinishPOISearchRequest];
        }];
    }
}

- (void) requestSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude
                        andSearchRadius:(double)searchRadius andKeywords:(NSArray *)keywords
{
    if ([self searchRequestIsAcceptableAtLatitude:latitude andLongitude:longitude]) {
        NSMutableArray * mutableOperations = [[NSMutableArray alloc] init];
        for (NSString * keyword in keywords) {
            NSString * requestString = [NSString stringWithFormat:
                                        @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%f&type=%@&key=AIzaSyDQM4-dDWzWIOk2YsIqJK6OzymxMllroeI",
                                        latitude, longitude, searchRadius, keyword];
            AFHTTPRequestOperation * requestOperation = [DataManager requestOperationWithString:requestString];
            [mutableOperations addObject:requestOperation];
        }
        [self operateSearchRequestWithOperations:mutableOperations];
    }
}

- (void) requestVaryingRadiusSearchForPOIsAtLatitude:(double)latitude andLongitude:(double)longitude andMaximumSearchRadius:(double)maximumSearchRadius
{
    if ([self searchRequestIsAcceptableAtLatitude:latitude andLongitude:longitude]) {
        NSMutableArray * mutableOperations = [[NSMutableArray alloc] init];
        for (int i = SEARCH_RADIUS_INCREMENT; i <= maximumSearchRadius; i+= SEARCH_RADIUS_INCREMENT) {
            NSString * requestString = [NSString stringWithFormat:
                                        @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&key=AIzaSyDQM4-dDWzWIOk2YsIqJK6OzymxMllroeI",
                                        latitude, longitude, i];
            AFHTTPRequestOperation * requestOperation = [DataManager requestOperationWithString:requestString];
            [mutableOperations addObject:requestOperation];
        }
        [self operateSearchRequestWithOperations:mutableOperations];
    }
}

#pragma mark - Operation Methods
- (void) operateSearchRequestWithOperations:(NSArray * /* of AFHTTPRequestOperation */)requestOperations
{
    NSArray * operations = [AFHTTPRequestOperation batchOfRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        // Progress Block
    } completionBlock:^(NSArray *operations) {
        for (AFHTTPRequestOperation * operation in operations) {
            if (operation.error) [self handlePOISearchFailed:operation];
            else [self handlePOISearchSuccess:operation];
        }
        [self didFinishPOISearchRequest];
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void) handlePOISearchSuccess:(AFHTTPRequestOperation *)operation
{
    //Uncomment to see Response String
    //NSLog(@"%@",[operation responseString]);
    
    NSData * responseData = [operation responseData];
    NSError * responseError;
    
    NSDictionary * responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&responseError];
    NSArray * searchResults = [responseJSON objectForKey:@"results"];
    
    int i = 0;
    for (NSDictionary * resultObject in searchResults) {
        NSDictionary * geometryObject = [resultObject objectForKey:@"geometry"];
        NSDictionary * locationObject = [geometryObject objectForKey:@"location"];
        
        double POILatitude = [[locationObject valueForKey:@"lat"] doubleValue];
        double POILongitude = [[locationObject valueForKey:@"lng"] doubleValue];
        NSString * POIName = [resultObject valueForKey:@"name"];
        NSString * POIPlaceID = [resultObject valueForKey:@"place_id"];
        
        PointOfInterest * POI = [[PointOfInterest alloc] initWithLatitude:POILatitude atLongitude:POILongitude
                                                                 withName:POIName andPlaceId:POIPlaceID];
        
        if (![CalculationUtilities POI:POI existsInArray:self.allPOIs]) {
            if (self.allPOIs.count > POI_QUOTA) {
                [self.allPOIs replaceObjectAtIndex:i withObject:POI];
            } else {
                [self.allPOIs addObject:POI];
            }
        }
        i++;
    }
}

- (void) handlePOISearchFailed:(AFHTTPRequestOperation *)operation
{
    NSLog(@"POI Search Request Failed");
}

- (void) didFinishPOISearchRequest
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataManagerDidFinishPOISearchRequest" object:nil];
}


//-------
//            //For Testing Only
//            if(self.dataIndex == 0 )
//            {
//                PointOfInterest * redTrainPOI = [[PointOfInterest alloc] initWithLatitude:30.576268 atLongitude:-96.348982 withName:@"Red Train" andPlaceId:@"TEST1"];
//                PointOfInterest * housePOI1 = [[PointOfInterest alloc] initWithLatitude:30.576839 atLongitude:-96.349615 withName:@"House 1" andPlaceId:@"TEST2"];
//                PointOfInterest * trainWreckPOI1 = [[PointOfInterest alloc] initWithLatitude:30.575587 atLongitude:-96.349968 withName:@"Trainwreck 1" andPlaceId:@"TEST3"];
//                PointOfInterest * buildingPOI1 = [[PointOfInterest alloc] initWithLatitude:30.576030 atLongitude:-96.350084 withName:@"Building 1" andPlaceId:@"TEST4"];
//                PointOfInterest * greyTrainPOI = [[PointOfInterest alloc] initWithLatitude:30.575990 atLongitude:-96.349773 withName:@"Grey Train" andPlaceId:@"TEST5"];
//                PointOfInterest * parkingLotPOI = [[PointOfInterest alloc] initWithLatitude:30.575168 atLongitude:-96.349791 withName:@"Parking Lot" andPlaceId:@"TEST6"];
//                PointOfInterest * trainWreckPOI2 = [[PointOfInterest alloc] initWithLatitude:30.576494 atLongitude:-96.349066 withName:@"Trainwreck 2" andPlaceId:@"TEST7"];
//
//                NSArray * POIArray = @[redTrainPOI, housePOI1, trainWreckPOI1, buildingPOI1, greyTrainPOI, parkingLotPOI, trainWreckPOI2];
//                [self.allPOIs addObjectsFromArray:POIArray];
//            }

@end
