//
//  AppDelegate.m
//  Education
//
//  Created by Feicun on 15/4/15.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

#define AVOS_ID @"szh8unfdcfy2vg9vn2ww4gegsd9b7jcrc7ojz58yxdhw41bk"
#define AVOS_KEY @"f0652hjcxk94wpmd9h3o201wscjh530645n66cw4d4o7pnkb"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [AVOSCloud setApplicationId:AVOS_ID clientKey:AVOS_KEY];
    setenv("LOG_CURL", "YES", 0);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
