//
//  SSSlaveOutputDevice.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 17/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SSSlaveOutputDevice : NSObject {
  NSInteger index;
  NSString *description;
}
@property (nonatomic, readonly) NSInteger index;

- (id)initWithIndex:(NSInteger)deviceIndex description:(NSString *)string;
@end
