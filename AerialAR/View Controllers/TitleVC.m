//
//  TitleVC.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/27/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "TitleVC.h"

#pragma mark - Private Declarations
@interface TitleVC ()

#pragma mark - Private Properties
@property CalculationKit * calculationKit;

#pragma mark - Calculation Kit Setup
- (void) setupCalculationKit;

@end

#pragma mark - Implementation
@implementation TitleVC

@synthesize calculationKit;

#pragma mark - View Load Methods
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //Sets delegate of text field to the View Controller
    self._RadiusField.delegate = self;
    self._POIField.delegate = self;
    self._FileNameField.delegate = self;
    self._FileExtensionField.delegate = self;
    self._XMLNameField.delegate = self;
    self._XMLRateField.delegate = self;
   
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Calculation Kit Setup
-(void)setupCalculationKit;
{
//    NSString * POITypes = self._POIField.text;  //Keywords seperated by comma
    NSString * XMLName = self._XMLNameField.text;
    
    DataManager * dataManager = [[DataManager alloc] initWithXMLName:XMLName];
    calculationKit = [[CalculationKit alloc] initWithDataManager:dataManager];
    
    //Sends values to kit and request search for POIs
}

#pragma mark - Segue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue to ImageOutputVC"]) {
        if([[segue destinationViewController] isKindOfClass:[ImageOutputVC class]])
        {
            [self setupCalculationKit];
            
            //Pass objects to the next view controller
            NSString * fileName = self._FileNameField.text;
            NSString * fileExtension = self._FileExtensionField.text;
            double searchRadius = [self._RadiusField.text doubleValue];
            
            ImageOutputVC * nextImageVC = (ImageOutputVC *)[segue destinationViewController];
            nextImageVC.calculationKit = calculationKit;
            nextImageVC.fileName = fileName;
            nextImageVC.fileExtension = fileExtension;
            nextImageVC.searchRadius = searchRadius;
        }
    }
    
    if ([[segue identifier] isEqualToString:@"Segue to VideoOutputVC"]) {
        if([[segue destinationViewController] isKindOfClass:[VideoOutputVC class]])
        {
            [self setupCalculationKit];

            NSString * fileName = self._FileNameField.text;
            NSString * fileExtension = self._FileExtensionField.text;
            double XMLRate = [self._XMLRateField.text doubleValue];
            double searchRadius = [self._RadiusField.text doubleValue];

            NSLog(@"%@, %@", fileName, fileExtension);
            
            //Pass objects to the next view controller
            VideoOutputVC * nextVideoVC = (VideoOutputVC *)[segue destinationViewController];
            nextVideoVC.calculationKit= calculationKit;
            nextVideoVC.fileName = fileName;
            nextVideoVC.fileExtension = fileExtension;
            nextVideoVC.XMLRate = XMLRate;
            nextVideoVC.searchRadius = searchRadius;
        }
    }
}
@end
