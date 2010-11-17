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

@interface SSSlave : NSObject {
@private
  BOOL connected;
  slimproto_t slimproto;
  slimaudio_t slimaudio;  
}
@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (BOOL)connect:(NSError **)error;
- (void)disconnect;
@end

