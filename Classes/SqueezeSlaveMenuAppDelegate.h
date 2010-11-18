//
//  SqueezeSlaveMenuAppDelegate.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSSlaveDelegate.h"

extern NSString *const SSServerHostDefaultKey;
extern NSString *const SSClientMACDefaultKey;

@class SSSlave, SSSlaveOutputDevice;

typedef enum {
  SSMenuStatusMenuItem = 1001,
  SSMenuDevicesStartSeparator,
  SSMenuDevicesEndSeparator,
  SSMenuConnectItem
} SSMenuStatusItems;

@interface SqueezeSlaveMenuAppDelegate : NSObject <NSApplicationDelegate, SSSlaveDelegate> {
  SSSlave *squeezeslave;
  SSSlaveOutputDevice *currentOutputDevice;
  NSArray *availableDevices;
  NSStatusItem *statusItem;
  NSWindowController *preferencesWindowController;
}
@property (retain) IBOutlet NSMenu *statusBarMenu;
@property (retain) NSArray *availableDevices;
@property (nonatomic, retain) SSSlaveOutputDevice *currentOutputDevice;

- (IBAction)toggleConnect:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (void)connect;
- (void)disconnect;
- (void)updateOutputDevices;
- (void)updateStatus:(NSString *)status;
- (void)handleError:(NSError *)error;
@end
