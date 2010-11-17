//
//  SSSlave.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <slimaudio/slimaudio.h>
#import <slimproto/slimproto.h>
#import "SSSlaveDelegate.h"

#define FIRMWARE_VERSION	2
#define SLIMPROTOCOL_PORT	3483
#define PLAYER_TYPE	8

extern NSString *const SSSlaveErrorDomain;

@class SSSlaveOutputDevice;

typedef enum {
  SSSlaveUnknownError = 0,
  SSSlaveInitializationError,
  SSSlaveConnectionError
} SSSlaveErrorCode;

@interface SSSlave : NSObject {
@private
  BOOL connected;
  slimproto_t slimproto;
  slimaudio_t slimaudio;
  NSString *macAddress;
  NSString *serverHost;
  SSSlaveOutputDevice *outputDevice;
  id<SSSlaveDelegate> delegate;
}
@property (nonatomic, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, copy) NSString *macAddress;
@property (nonatomic, assign) id<SSSlaveDelegate> delegate;

- (id)initWithHost:(NSString *)host outputDevice:(SSSlaveOutputDevice *)device;
- (BOOL)connect:(NSError **)error;
- (void)disconnect;
@end

int connect_callback(slimproto_t *p, bool isConnected, void *user_data);

@interface SSSlave (AudioDevices)
+ (NSArray *)availableOutputDevices:(NSError **)error;
@end