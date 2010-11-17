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

extern NSString *const SSSlaveErrorDomain;

typedef enum {
  SSSlaveUnknownError = 0,
  SSSlaveInitializationError,
  SSSlaveConnectionError
} SSSlaveErrorCode;

@class SSSlave;

@protocol SSSlaveDelegate <NSObject>
@optional
- (void)slaveDidConnect:(SSSlave *)slave;
- (void)slaveDidDisconnect:(SSSlave *)slave;
@end

@interface SSSlave : NSObject {
@private
  BOOL connected;
  slimproto_t slimproto;
  slimaudio_t slimaudio;
  NSString *macAddress;
  NSString *serverHost;
  NSInteger audioDeviceIndex;
  id<SSSlaveDelegate> delegate;
}
@property (nonatomic, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, copy) NSString *macAddress;
@property (nonatomic, assign) id<SSSlaveDelegate> delegate;

- (id)initWithHost:(NSString *)host audioDeviceIndex:(NSInteger)deviceIndex;
- (BOOL)connect:(NSError **)error;
- (void)disconnect;
@end

