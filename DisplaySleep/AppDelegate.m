//
//  AppDelegate.m
//  DisplaySleep
//
//  Created by Numeric on 12/7/17.
//  Copyright © 2017 Numeric. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSMenu *menu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"S";
    _statusItem.highlightMode = YES;
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(sleep:)];
}

- (void)sleep:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pmset"];
    [task setArguments:[NSArray arrayWithObjects:@"displaysleepnow", nil]];
    [task launch];
}

@end
