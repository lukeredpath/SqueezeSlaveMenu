//
//  SqueezeSlaveMenuAppDelegate.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSSlave;

@interface SqueezeSlaveMenuAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  NSTextField *statusLabel;
  SSSlave *squeezeslave;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSTextField *statusLabel;

- (IBAction)toggleConnect:(NSButton *)button;
@end
