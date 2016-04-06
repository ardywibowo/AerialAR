//
//  TitleVC.h
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/27/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <ImageIO/ImageIO.h>

#import "DataManager.h"
#import "CalculationKit.h"

#import "ImageOutputVC.h"
#import "VideoOutputVC.h"
#import "HelpVC.h"

@interface TitleVC : UIViewController <UITextFieldDelegate, NSXMLParserDelegate>

#pragma mark - Text Input Field Outlets
@property (weak, nonatomic) IBOutlet UITextField * _POIField;
@property (weak, nonatomic) IBOutlet UITextField * _RadiusField;
@property (strong, nonatomic) IBOutlet UITextField * _FileNameField;
@property (strong, nonatomic) IBOutlet UITextField * _FileExtensionField;
@property (strong, nonatomic) IBOutlet UITextField * _XMLNameField;
@property (strong, nonatomic) IBOutlet UITextField * _XMLRateField;

@end