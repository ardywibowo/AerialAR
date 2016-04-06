//
//  AppDelegate.m
//  AerialAR
//
//  Created by Randy Ardywibowo on 8/28/14.
//  Copyright (c) 2014 Dr. Robin Murphy's Robotics Research Laboratory. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    // Override point for customization after application launch.
//    [AppDelegate createDataDirectory];
//    
//    // Save bundles to Document Directory
//    NSArray * dataBundlePaths = [AppDelegate getDataArrayFromMainBundle];
//    for (NSString * dataBundlePath in dataBundlePaths) {
//        NSString * bundleName = [[dataBundlePath lastPathComponent] stringByDeletingPathExtension];
//        NSString * dataPath = [AppDelegate dataPathWithBundleName:bundleName];
//        
//        NSError * error = nil;
//        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error];
//        if (error != nil) {
//            NSLog(@"Error Creating Directory: %@", error);
//        }
//        
//        //Get Contents of bundle
//        NSString * mediaDirectory = [dataBundlePath stringByAppendingPathComponent:@"Media"];
//        NSString * mediaDataDirectory = [dataPath stringByAppendingPathComponent:@"Media"];
//        if ([[NSFileManager defaultManager] isReadableFileAtPath:mediaDirectory]) {
//            NSError * error = nil;
//            [[NSFileManager defaultManager] copyItemAtPath:mediaDirectory toPath:mediaDataDirectory error:&error];
//
//            // Uncomment to see Error Log
//            //if (error != nil) NSLog(@"%@", error);
//        }
//        
//        NSString * XMLDirectory = [dataBundlePath stringByAppendingPathComponent:@"XML"];
//        NSString * XMLDataDirectory = [dataPath stringByAppendingPathComponent:@"XML"];
//        if ([[NSFileManager defaultManager] isReadableFileAtPath:XMLDirectory]) {
//            NSError * error = nil;
//            [[NSFileManager defaultManager] copyItemAtPath:XMLDirectory toPath:XMLDataDirectory error:&error];
//            
//            // Uncomment to see Error Log
//            //if (error != nil) NSLog(@"%@", error);
//        }
//    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - Initialization Methods
//
//+ (NSString *) dataPathWithBundleName:(NSString *)bundleName
//{
//    NSString * dataFolderPath = [AppDelegate dataFolderPath];
//    NSString * dataPath = [dataFolderPath stringByAppendingPathComponent:bundleName];
//    
//    return dataPath;
//}
//
//+ (NSString *) dataFolderPath
//{
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSString * dataFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Data"];
//    
//    return dataFolderPath;
//}
//
//+ (void) createDataDirectory
//{
//    // Creates a new directory for data if it doesn't exist
//    NSString * dataFolderPath = [AppDelegate dataFolderPath];
//    NSError * error = nil;
//    [[NSFileManager defaultManager] createDirectoryAtPath:dataFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
//    
//    if (error != nil) {
//        NSLog(@"Error Creating Directory: %@", error);
//    }
//}
//
//+ (NSArray *) getDataArrayFromMainBundle
//{
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    NSString * mainBundlePath = [[NSBundle mainBundle] bundlePath];
//    NSArray * fileList = [fileManager contentsOfDirectoryAtPath:mainBundlePath error:nil];
//    
//    NSString * bundleExtension = @"bundle";
//    fileList = [fileList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", bundleExtension]];
//    
//    NSMutableArray * fileDirectories = [[NSMutableArray alloc] init];
//    for (NSString * fileName in fileList) {
//        NSString * fileDirectory = [mainBundlePath stringByAppendingPathComponent:fileName];
//        [fileDirectories addObject:fileDirectory];
//    }
//    
//    return fileDirectories;
//}

@end
