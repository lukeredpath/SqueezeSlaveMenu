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
@synthesize currentOutputDevice;
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
  [self updateOutputDevices];
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

- (void)updateOutputDevices
{
  self.availableDevices = [SSSlave availableOutputDevices:nil];
  self.currentOutputDevice = [self.availableDevices objectAtIndex:0];
  
  NSInteger indexOfFirstSeparator = [self.statusBarMenu indexOfItem:[self.statusBarMenu itemWithTag:SSMenuDevicesStartSeparator]];
  NSInteger indexOfLastSeparator  = [self.statusBarMenu indexOfItem:[self.statusBarMenu itemWithTag:SSMenuDevicesEndSeparator]];
  
  if (indexOfLastSeparator > (indexOfFirstSeparator + 1)) {
    for (int i = indexOfFirstSeparator + 1; i < indexOfLastSeparator; i++) {
      [self.statusBarMenu removeItemAtIndex:i];
    }
  }
  for (int i = 0; i < self.availableDevices.count; i++) {
    SSSlaveOutputDevice *device = [self.availableDevices objectAtIndex:i];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[device description] action:@selector(outputDeviceSelected:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    if (device == self.currentOutputDevice) {
      [menuItem setState:1];
    }
    [self.statusBarMenu insertItem:menuItem atIndex:(indexOfFirstSeparator + 1 + i)];
    [menuItem release];
  }
}

- (void)setCurrentOutputDevice:(SSSlaveOutputDevice *)outputDevice
{
  [currentOutputDevice autorelease];
  currentOutputDevice = [outputDevice retain];
  [squeezeslave release], squeezeslave = nil;
}

- (void)connect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (squeezeslave == nil) {
    squeezeslave = [[SSSlave alloc] initWithHost:@"mac-mini.local" outputDevice:self.currentOutputDevice];
    squeezeslave.delegate = self;
  }
  NSError *error = nil;
  
  [self updateStatus:@"Connecting..."];
  
  if(![squeezeslave connect:&error]) {
    [self updateStatus:@"Disconnected"];
  }
  [pool release];
}

- (void)disconnect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [squeezeslave disconnect];
  [pool release];
}

- (void)updateStatus:(NSString *)status;
{
  [[self.statusBarMenu itemWithTag:SSMenuStatusMenuItem] setTitle:[NSString stringWithFormat:@"Status: %@", status]];
}

#pragma mark -
#pragma mark SSSlaveDelegate methods

- (void)slaveDidConnect:(SSSlave *)slave
{
  [self updateStatus:@"Connected"];
}

- (void)slaveDidDisconnect:(SSSlave *)slave
{
  [self updateStatus:@"Disconnected"];
}

@end
