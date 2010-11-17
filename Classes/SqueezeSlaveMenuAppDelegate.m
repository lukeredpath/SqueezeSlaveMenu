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
@synthesize connectButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  squeezeslave = [[SSSlave alloc] initWithHost:@"mac-mini.local" audioDeviceIndex:2];
  squeezeslave.delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  [squeezeslave disconnect];
}

- (IBAction)toggleConnect:(id)sender;
{
  [connectButton setEnabled:NO];
  
  if (squeezeslave.isConnected) {
    [self performSelectorInBackground:@selector(disconnect) withObject:nil];
  } else {
    [self performSelectorInBackground:@selector(connect) withObject:nil];
  }
}

- (void)connect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSError *error = nil;
  if(![squeezeslave connect:&error]) {
    [self.statusLabel setStringValue:[NSString stringWithFormat:@"Connection failed, %@", [error localizedDescription]]];
    [connectButton setEnabled:YES];
  }
  [pool release];
}

- (void)disconnect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [squeezeslave disconnect];
  [pool release];
}

#pragma mark -
#pragma mark SSSlaveDelegate methods

- (void)slaveDidConnect:(SSSlave *)slave
{
  [self.statusLabel setStringValue:@"Connected"];
  [connectButton setTitle:@"Disconnect"];
  [connectButton setEnabled:YES];
}

- (void)slaveDidDisconnect:(SSSlave *)slave
{
  [self.statusLabel setStringValue:@"Disconnected"];
  [connectButton setTitle:@"Connect"];
  [connectButton setEnabled:YES];
}

@end
