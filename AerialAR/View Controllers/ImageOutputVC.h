//
//  ImageOutputVC.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataManager.h"
#import "CalculationKit.h"

#import "POIView.h"
#import "DrawingRecognizer.h"

#pragma mark - Public Declarations
@interface ImageOutputVC : UIViewController <POIViewDelegate>

#pragma  mark - Buttons
@property (strong, nonatomic) IBOutlet UIBarButtonItem * nextImageButton;

#pragma mark - Properties
@property CalculationKit * calculationKit;
@property NSString * fileName;
@property NSString * fileExtension;
@property double searchRadius;

@end
