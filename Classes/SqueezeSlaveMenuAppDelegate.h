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
  NSWindow *window;
  NSTextField *statusLabel;
  NSButton *connectButton;
  SSSlave *squeezeslave;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSTextField *statusLabel;
@property (retain) IBOutlet NSButton *connectButton;

- (IBAction)toggleConnect:(id)sender;
@end
