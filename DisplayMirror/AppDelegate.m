//
//  AppDelegate.m
//  DisplaySleep
//
//  Created by Blue on 9/4/18.
//  Copyright © 2018 Blue. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, MirrorAction) {
    help,
    on,
    off,
    toggle,
    query,
    linkDiplays,
};

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSMenu *menu;
@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"M";
    _statusItem.highlightMode = YES;
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(toggleOnOffDisplayMirroring)];
}

#define MAX_DISPLAYS 10
#define SECONDARY_DISPLAY_COUNT 9
static CGDisplayCount numberOfTotalDspys = MAX_DISPLAYS;
static CGDirectDisplayID activeDspys[MAX_DISPLAYS];
static CGDirectDisplayID onlineDspys[MAX_DISPLAYS];
static CGDirectDisplayID secondaryDspys[SECONDARY_DISPLAY_COUNT];

NSString* screenNameForDisplay(CGDirectDisplayID displayID) {
    NSString *screenName = nil;
    NSDictionary *deviceInfo = (__bridge NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName);
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
    if ([localizedNames count] > 0) {
        screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
    }
    return screenName;
}

CGError multiConfigureDisplays(CGDisplayConfigRef configRef, CGDirectDisplayID *secondaryDspys, int count, CGDirectDisplayID master) {
    CGError error = kCGErrorSuccess;
    for (int i = 0; i<count; i++) {
        CGDirectDisplayID currentID = secondaryDspys[i];
        CGError errorResult = CGConfigureDisplayMirrorOfDisplay(configRef, currentID, master);

        if (errorResult) {
            error = errorResult;
        }
    }
    return error;
}

- (CGError)toggleOnOffDisplayMirroring {
    int masterIndex, slaveIndex;
    MirrorAction action = toggle;

    CGDisplayCount numberOfActiveDspys;
    CGDisplayCount numberOfOnlineDspys;

    CGDisplayErr activeError = CGGetActiveDisplayList(numberOfTotalDspys,activeDspys,&numberOfActiveDspys);

    if (activeError!=0) {
        printf("Error in obtaining active diplay list: %d\n",activeError);
        return activeError;
    }

    CGDisplayErr onlineError = CGGetOnlineDisplayList (numberOfTotalDspys,onlineDspys,&numberOfOnlineDspys);

    if (onlineError!=0) {
        printf("Error in obtaining online diplay list: %d\n",onlineError);
        return onlineError;
    }

    if (numberOfOnlineDspys<2) {
        printf("No secondary display detected.\n");
        return 1;
    }

    bool displaysMirrored = CGDisplayIsInMirrorSet(CGMainDisplayID());
    int secondaryDisplayIndex = 0;
    for (int displayIndex = 0; displayIndex<numberOfOnlineDspys; displayIndex++) {
        if (onlineDspys[displayIndex] != CGMainDisplayID()) {
            secondaryDspys[secondaryDisplayIndex] = onlineDspys[displayIndex];
            secondaryDisplayIndex++;
        }
    }

    if (action == toggle) {
        if (displaysMirrored) {
            action = off;
        } else {
            action = on;
        }
    }

    CGDisplayConfigRef configRef;
    CGError err = CGBeginDisplayConfiguration (&configRef);
    if (err != 0) {
        printf("Error with CGBeginDisplayConfiguration: %d\n",err);
        return err;
    }

    switch (action) {
        case on:
            err = multiConfigureDisplays(configRef, secondaryDspys, numberOfOnlineDspys - 1, CGMainDisplayID());
            break;
        case off:
            err = multiConfigureDisplays(configRef, secondaryDspys, numberOfOnlineDspys - 1, kCGNullDirectDisplay);
            break;
        case query:
            if (displaysMirrored) {
                printf("on\n");
            } else {
                printf("off\n");
            }
            break;
        case linkDiplays:
            if (numberOfOnlineDspys <= masterIndex) {
                printf("Index of specified master display out of bounds\n");
                return 1;
            }
            if (numberOfOnlineDspys <= slaveIndex) {
                printf("Index of slave display out of bounds\n");
                return 1;
            }
            err = CGConfigureDisplayMirrorOfDisplay(configRef, onlineDspys[slaveIndex], onlineDspys[masterIndex]);
            break;
        default:
            break;
    }
    if (err != 0) printf("Error configuring displays: %d\n",err);

    // Apply the changes
    err = CGCompleteDisplayConfiguration (configRef,kCGConfigurePermanently);
    if (err != 0) printf("Error applying configuration: %d\n",err);

    return err;

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
