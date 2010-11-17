//
//  SqueezeSlaveMenuAppDelegate.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SqueezeSlaveMenuAppDelegate.h"
#import "SSSlave.h"

@implementation SqueezeSlaveMenuAppDelegate

@synthesize window;
@synthesize statusLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  squeezeslave = [[SSSlave alloc] init];
}

- (IBAction)toggleConnect:(NSButton *)button;
{
  [button setEnabled:NO];
  
  if (squeezeslave.isConnected) {
    [squeezeslave disconnect];
    [self.statusLabel setStringValue:@"Disconnected"];
    [button setTitle:@"Connect"];
    [button setEnabled:YES];
  } else {
    NSError *error = nil;
    if([squeezeslave connect:&error]) {
      [self.statusLabel setStringValue:@"Connected"];
      [button setTitle:@"Disconnect"];
      [button setEnabled:YES];
    } else {
      [self.statusLabel setStringValue:[NSString stringWithFormat:@"Connection failed, %@", [error localizedDescription]]];
      [button setEnabled:YES];
    }    
  }
}

@end
