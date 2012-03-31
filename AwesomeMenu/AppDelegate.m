//
//  AppDelegate.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "AppDelegate.h"
#import "AwesomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    AwesomeViewController *viewController = [[AwesomeViewController alloc] init];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
