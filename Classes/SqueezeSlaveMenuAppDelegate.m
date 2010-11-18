//
//  SqueezeSlaveMenuAppDelegate.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SqueezeSlaveMenuAppDelegate.h"
#import "SSSlave.h"

#define kAudioDeviceMenuTagBase 2000

NSString *const SSServerHostDefaultKey = @"ServerHost";
NSString *const SSClientMACDefaultKey  = @"ClientMAC";

@implementation SqueezeSlaveMenuAppDelegate

@synthesize availableDevices;
@synthesize currentOutputDevice;
@synthesize statusBarMenu;

+ (void)initialize
{
  NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"DefaultSettings" ofType:@"plist"];
  NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

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

- (IBAction)toggleConnect:(NSMenuItem *)sender;
{
  if (squeezeslave.isConnected) {
    [sender setTitle:@"Connect To Server"];
    [self performSelectorInBackground:@selector(disconnect) withObject:nil];
  } else {
    [sender setTitle:@"Disconnect"];
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
    [menuItem setTag:kAudioDeviceMenuTagBase+i];
    [menuItem setEnabled:YES];
    if (device == self.currentOutputDevice) {
      [menuItem setState:1];
    }
    [self.statusBarMenu insertItem:menuItem atIndex:(indexOfFirstSeparator + 1 + i)];
    [menuItem release];
  }
}

- (void)outputDeviceSelected:(NSMenuItem *)sender
{
  NSInteger indexOfCurrentOutputDevice = [self.availableDevices indexOfObject:self.currentOutputDevice];
  NSMenuItem *currentMenuItem = [self.statusBarMenu itemWithTag:kAudioDeviceMenuTagBase+indexOfCurrentOutputDevice];
  [currentMenuItem setState:0];  
  self.currentOutputDevice = [self.availableDevices objectAtIndex:sender.tag - kAudioDeviceMenuTagBase];
  [sender setState:1];
}

- (void)setCurrentOutputDevice:(SSSlaveOutputDevice *)outputDevice
{
  if (squeezeslave.isConnected) {
    [self toggleConnect:[self.statusBarMenu itemWithTag:SSMenuConnectItem]];
  }
  [currentOutputDevice autorelease];
  currentOutputDevice = [outputDevice retain];
}

- (void)connect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (squeezeslave == nil) {
    squeezeslave = [[SSSlave alloc] initWithHost:[[NSUserDefaults standardUserDefaults] stringForKey:SSServerHostDefaultKey] 
                                      MACAddress:[[NSUserDefaults standardUserDefaults] stringForKey:SSClientMACDefaultKey] 
                                    outputDevice:self.currentOutputDevice];
    
    squeezeslave.delegate = self;
  }
  NSError *error = nil;
  
  [self updateStatus:@"Connecting..."];
  
  if(![squeezeslave connect:&error]) {
    [[self.statusBarMenu itemWithTag:SSMenuConnectItem] setTitle:@"Connect To Server"];
    [self updateStatus:@"Disconnected"];
    [self handleError:error];
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

- (void)handleError:(NSError *)error;
{
  [[NSAlert alertWithError:error] runModal];
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
  [squeezeslave release], squeezeslave = nil;
}

@end
