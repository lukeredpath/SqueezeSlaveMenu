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
  
  NSError *error = nil;
  
  if(![squeezeslave connect:&error]) {
    [self.statusLabel setStringValue:[NSString stringWithFormat:@"Connection failed, %@", [error localizedDescription]]];
  }
}

@end
