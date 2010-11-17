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

@synthesize availableDevices;
@synthesize statusBarMenu;

- (void)awakeFromNib
{
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
  [statusItem setMenu:statusBarMenu];
  [statusItem setTitle:@"SS"];
  [statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  self.availableDevices = [SSSlave availableOutputDevices:nil];
  
  squeezeslave = [[SSSlave alloc] initWithHost:@"mac-mini.local" outputDevice:[self.availableDevices objectAtIndex:0]];
  squeezeslave.delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  [squeezeslave disconnect];
}

- (IBAction)toggleConnect:(id)sender;
{
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

}

- (void)slaveDidDisconnect:(SSSlave *)slave
{

}

@end
