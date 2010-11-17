//
//  SSSlaveDelegate.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 17/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSSlave;

@protocol SSSlaveDelegate <NSObject>
@optional
- (void)slaveDidConnect:(SSSlave *)slave;
- (void)slaveDidDisconnect:(SSSlave *)slave;
@end
