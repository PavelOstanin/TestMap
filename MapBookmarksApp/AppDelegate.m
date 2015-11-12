//
//  AppDelegate.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 09/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "AppDelegate.h"
#import "POCoreDataManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[POCoreDataManager shared] saveContext];
}

@end
