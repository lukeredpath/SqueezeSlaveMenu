//
//  SqueezeSlaveMenuAppDelegate.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSSlaveDelegate.h"

@interface SqueezeSlaveMenuAppDelegate : NSObject <NSApplicationDelegate, SSSlaveDelegate> {
  SSSlave *squeezeslave;
  NSArray *availableDevices;
  NSStatusItem *statusItem;
}
@property (retain) IBOutlet NSMenu *statusBarMenu;
@property (retain) NSArray *availableDevices;

- (IBAction)toggleConnect:(id)sender;
@end
