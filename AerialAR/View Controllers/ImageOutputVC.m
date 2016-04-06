//
//  ImageOutputVC.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "ImageOutputVC.h"

#pragma mark - Private Declarations
@interface ImageOutputVC ()

#pragma  mark - Properties
@property NSString * imageNameWithExtension;
@property UIImage * workingImage;
@property UIImageView * pictureView;
@property POIView * poiView;
@property CGRect drawingArea;
@property DrawingRecognizer * ellipseGR;

@property UILabel * selectionDataLabel;

@property NSArray * ellipsePoints;

#pragma mark - Button Click Refresh Method
-(void)refreshView;

@end

#pragma mark - Implementation
@implementation ImageOutputVC

//Public
@synthesize calculationKit;
@synthesize fileName;
@synthesize fileExtension;
@synthesize imageNameWithExtension;

//Private
@synthesize workingImage;
@synthesize pictureView;
@synthesize poiView;
@synthesize drawingArea;
@synthesize ellipseGR;

@synthesize selectionDataLabel;

#pragma mark - View Load Methods
- (void) viewDidLoad
{
    [super viewDidLoad];
    //[self.view addSubview:[UIActivityIndicatorView]];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePOIView)
                                                 name:@"dataManagerDidFinishPOISearchRequest"
                                               object:nil];
    
    [calculationKit.dataManager requestSearchForPOIsAtLatitude:calculationKit.dataManager.cameraLatitude
                                                  andLongitude:calculationKit.dataManager.cameraLongitude
                                               andSearchRadius:self.searchRadius];
    [self initializePictureView];
    
    imageNameWithExtension = [NSString stringWithFormat:@"%@%d.%@", fileName, calculationKit.dataManager.XMLDataIndex, fileExtension];
    if ([DataManager fileExistsWithNameAndExtension:imageNameWithExtension]) {
        workingImage = [UIImage imageNamed:imageNameWithExtension];
        [pictureView setImage:workingImage];
        drawingArea = [POIView CGRectOfMediaSize:workingImage.size FitInViewRect:pictureView.frame];
    }
    else {
        drawingArea = self.view.frame;
    }
    
    [self initializePOIView];
    [self initializeEllipseGestureRecognizerForView:poiView];
    [self initializeSelectionLabel];
    
    [self.view addSubview:pictureView];
    [self.view addSubview:poiView];
    [self.view addSubview:selectionDataLabel];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Click Handlers
- (IBAction) onPrevClick:(id) sender
{
    [calculationKit.dataManager decrementIndex];
    imageNameWithExtension = [NSString stringWithFormat:@"%@%d.%@", fileName, calculationKit.dataManager.XMLDataIndex, fileExtension];
    if ([DataManager fileExistsWithNameAndExtension:imageNameWithExtension])
        [self refreshView];
    else [calculationKit.dataManager incrementIndex];
}

- (IBAction) onNextClick:(id) sender
{
    [calculationKit.dataManager incrementIndex];
    imageNameWithExtension = [NSString stringWithFormat:@"%@%d.%@", fileName, calculationKit.dataManager.XMLDataIndex, fileExtension];
    if ([DataManager fileExistsWithNameAndExtension:imageNameWithExtension])
        [self refreshView];
    else [calculationKit.dataManager decrementIndex];
}

#pragma mark - Initialization Methods
- (void) initializePictureView
{
    pictureView = [[UIImageView alloc] init];
    pictureView.frame = self.view.frame;
    pictureView.contentMode = UIViewContentModeScaleAspectFit;
    pictureView.backgroundColor = [UIColor blackColor];
}

- (void) initializePOIView
{
    self.poiView = [[POIView alloc] initWithFrame:drawingArea];
    poiView.delegate = self;
}

- (void) initializeEllipseGestureRecognizerForView:(UIView *)gestureView
{
    ellipseGR = [[DrawingRecognizer alloc] initWithView:gestureView];
    [ellipseGR addTarget:self.poiView action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:ellipseGR];
}

- (void) initializeSelectionLabel
{
    CGRect selectionDataFrame = CGRectMake(poiView.frame.origin.x, poiView.frame.origin.y+self.navigationController.navigationBar.frame.size.height, poiView.frame.size.width/6, poiView.frame.size.height/10);
    selectionDataLabel = [[UILabel alloc] initWithFrame:selectionDataFrame];
    selectionDataLabel.numberOfLines = 0;
    selectionDataLabel.font = [UIFont systemFontOfSize:5];
    
    selectionDataLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1  alpha:1.0];
    selectionDataLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.7 alpha:0.70];
    selectionDataLabel.text = @"Latitude:\nLongitude:\nMin. Radius:\nMax Radius:";
}

#pragma mark - Update and Refresh Methods
- (void) updatePOIView
{
    [calculationKit calculateScreenRatioOfPOIs];
    [self.poiView updatePOIs:[calculationKit getCopyOfVisiblePoints]];
}

- (void) refreshView
{
    //Erase previous view
    [self.poiView eraseView];
    
    // Set new image
    workingImage = [UIImage imageNamed:imageNameWithExtension];
    [pictureView setImage:workingImage];
    
    // Set new frame for poiView
    drawingArea = [POIView CGRectOfMediaSize:workingImage.size FitInViewRect:pictureView.frame];
    [self.poiView setFrame:drawingArea];
    
    // Calculate new POI location values
    [calculationKit.dataManager setCameraOrientationData];
    [calculationKit.dataManager requestSearchForPOIsAtLatitude:calculationKit.dataManager.cameraLatitude
                                                  andLongitude:calculationKit.dataManager.cameraLongitude
                                               andSearchRadius:self.searchRadius];
    
    // Set new frame for selection label
    CGRect selectionDataFrame = CGRectMake(poiView.frame.origin.x, poiView.frame.origin.y+self.navigationController.navigationBar.frame.size.height, poiView.frame.size.width/6, poiView.frame.size.height/10);
    [selectionDataLabel setFrame:selectionDataFrame];
}

- (void) selectionPointRatiosPassed:(NSArray *)eP
{
    self.ellipsePoints = eP;
    [self calculateSelectionRadiuses];
    [calculationKit.dataManager requestSearchForPOIsAtLatitude:calculationKit.selectionCenterLatitude
                                                  andLongitude:calculationKit.selectionCenterLongitude
                                               andSearchRadius:calculationKit.selectionRadiusMinimum];
    [self.poiView setNeedsDisplay];
}

- (void) calculateSelectionRadiuses
{
    [calculationKit calculateRadiusesOfSelectionPointsForSelectionPointRatios:self.ellipsePoints];
    [calculationKit calculateGPSOfSelectionCenter];
    
    NSLog(@"Minimum Radius %f", calculationKit.selectionRadiusMinimum);
    NSLog(@"Maximum Radius %f", calculationKit.selectionRadiusMaximum);
    NSLog(@"Selection Latitude %f", calculationKit.selectionCenterLatitude);
    NSLog(@"Selection Longitude %f", calculationKit.selectionCenterLongitude);
    
    selectionDataLabel.text = [NSString stringWithFormat:@"Latitude: %f\nLongitude: %f\nMin. Radius: %f ft\nMax Radius: %f ft",
                               calculationKit.selectionCenterLatitude,
                               calculationKit.selectionCenterLongitude,
                               calculationKit.selectionRadiusMinimum,
                               calculationKit.selectionRadiusMaximum];
    
}

@end
