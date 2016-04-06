//
//  VideoOutputVC.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "VideoOutputVC.h"

#pragma mark - Private Declarations
@interface VideoOutputVC ()

@property NSString * videoNameWithExtension;
@property POIView * poiView;
@property MPMoviePlayerController * MPC;
@property CGRect drawingArea;
@property DrawingRecognizer * ellipseGR;
@property (nonatomic) NSMutableArray * allPOIArrays;       //of NSArray of PointOfInterest
@property NSTimer * POIUpdateTimer;

@property int dataIndex;

- (void) handleDidFinishPOISearch;
- (void) handleMoviePlayerLoadStateDidChange;
- (void) updatePOIView;

@end

#pragma mark - Implementation
@implementation VideoOutputVC

//Public
@synthesize calculationKit;
@synthesize fileName;
@synthesize fileExtension;
@synthesize XMLRate;

//Private
@synthesize videoNameWithExtension;
@synthesize poiView;
@synthesize drawingArea;
@synthesize MPC;
@synthesize ellipseGR;
@synthesize POIUpdateTimer;
@synthesize  dataIndex;

#pragma mark - Lazy Instantiation
- (NSMutableArray * /* of NSArray of PointOfInterest */) allPOIArrays {
    if (!_allPOIArrays) {
        _allPOIArrays = [[NSMutableArray alloc] init];
    }
    return _allPOIArrays;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidFinishPOISearch)
                                                 name:@"dataManagerDidFinishPOISearchRequest"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMoviePlayerLoadStateDidChange)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [calculationKit.dataManager requestSearchForPOIsAtLatitude:calculationKit.dataManager.cameraLatitude
                                                  andLongitude:calculationKit.dataManager.cameraLongitude
                                               andSearchRadius:self.searchRadius];
    
    videoNameWithExtension = [NSString stringWithFormat:@"%@.%@", fileName, fileExtension];
    if([DataManager fileExistsWithNameAndExtension:videoNameWithExtension])
    {
        //Add video from media file
        NSString * videoPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
        NSURL * videoURL = [NSURL fileURLWithPath:videoPath];
        MPC = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        
        //MPC Initilization
        [MPC setMovieSourceType:MPMovieSourceTypeFile];
        MPC.view.frame = self.view.frame;
        MPC.fullscreen = NO;
        MPC.scalingMode = MPMovieScalingModeAspectFit;

        //Play video
        [MPC prepareToPlay];
        [self.view addSubview:MPC.view];
        
        MPC.view.opaque = NO;
        [MPC.view setBackgroundColor:[UIColor clearColor]];
    }
    else drawingArea = self.view.frame;
    
    //Create view for POIs
    poiView = [[POIView alloc] init];
    [self.view addSubview:poiView];

    //Add gesture recognizer to poiView
    ellipseGR = [[DrawingRecognizer alloc] initWithView:poiView];
    [ellipseGR addTarget:self.poiView action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:ellipseGR];
}

- (void) handleDidFinishPOISearch
{
    [calculationKit calculateScreenRatioOfPOIs];
    [self.allPOIArrays addObject:[calculationKit getCopyOfVisiblePoints]];
    
    [calculationKit.dataManager incrementIndex];
    if([calculationKit.dataManager cameraOrientationDataExistsForCurrentIndex])
        [calculationKit.dataManager requestSearchForPOIsAtLatitude:calculationKit.dataManager.cameraLatitude
                                                      andLongitude:calculationKit.dataManager.cameraLongitude
                                                   andSearchRadius:self.searchRadius];
}

- (void) handleMoviePlayerLoadStateDidChange
{
    if(MPC.loadState == MPMovieLoadStatePlayable | MPC.loadState == MPMovieLoadStatePlaythroughOK)
    {
        drawingArea = [POIView CGRectOfMediaSize:MPC.naturalSize FitInViewRect:MPC.view.frame];
        [self.poiView setFrame:drawingArea];
        
        float timeInterval = 1.0/XMLRate;
        
        [self updatePOIView];
        POIUpdateTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updatePOIView) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:POIUpdateTimer forMode:NSRunLoopCommonModes];
    }
}

- (void) updatePOIView
{
    double timeInterval = 1.0/XMLRate;
    
    if(self.dataIndex < self.allPOIArrays.count)
    {
        [poiView updatePOIs:self.allPOIArrays[self.dataIndex]];
        [poiView setNeedsDisplay];
    }
    else [POIUpdateTimer invalidate];
    
    if(self.dataIndex+1 < self.allPOIArrays.count)
        [poiView animateToPOIs:self.allPOIArrays[self.dataIndex+1] withDuration:timeInterval];
    
    self.dataIndex++;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [POIUpdateTimer invalidate];
}

@end
