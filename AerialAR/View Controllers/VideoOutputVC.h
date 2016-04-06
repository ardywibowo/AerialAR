//
//  VideoOutputVC.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CalculationKit.h"
#import "POIView.h"
#import "DrawingRecognizer.h"

#pragma mark - Public Declarations
@interface VideoOutputVC : UIViewController

#pragma mark - Properties
@property CalculationKit * calculationKit;
@property (nonatomic) double XMLRate;
@property NSString * fileName;
@property NSString * fileExtension;
@property double searchRadius;

@end