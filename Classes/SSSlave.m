//
//  SSSlave.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SSSlave.h"

NSString *const SSSlaveErrorDomain = @"SSSlaveErrorDomain";

@implementation SSSlave

- (id)init 
{
  if ((self = [super init])) {

  }
  
  return self;
}

- (void)dealloc 
{  
    
  [super dealloc];
}

- (BOOL)connect:(NSError **)error;
{
  *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveUnknownError userInfo:nil];

  return NO;
}

@end
