//
//  AppDelegate.m
//  DisplaySleep
//
//  Created by Blue on 9/4/18.
//  Copyright © 2018 Blue. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
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


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
