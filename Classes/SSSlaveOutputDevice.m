//
//  SSSlaveOutputDevice.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 17/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SSSlaveOutputDevice.h"


@implementation SSSlaveOutputDevice

@synthesize index;

- (id)initWithIndex:(NSInteger)deviceIndex description:(NSString *)string;
{
  if (self = [super init]) {
    index = deviceIndex;
    description = [string copy];
  }
  return self;
}

- (void)dealloc
{
  [description release];
  [super dealloc];
}

- (NSString *)description
{
  return description;
}

@end
