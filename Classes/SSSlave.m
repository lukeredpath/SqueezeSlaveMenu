//
//  SSSlave.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SSSlave.h"

@interface SSSlave ()
- (void)handleSlimprotoConnect:(bool)isConnected;
@end

#define RETRY_DEFAULT	5
#define LINE_COUNT	2
#define OPTLEN		64
#define FIRMWARE_VERSION	2
#define SLIMPROTOCOL_PORT	3483
#define PLAYER_TYPE	8

bool modify_latency = false;
unsigned int user_latency = 0L;

bool output_change = false;

const char *version = "0.9";
const int revision = 208;
static int port = SLIMPROTOCOL_PORT;
static int firmware = FIRMWARE_VERSION;
static int player_type = PLAYER_TYPE;

int connect_callback(slimproto_t *p, bool isConnected, void *user_data) {
  [(SSSlave *)user_data handleSlimprotoConnect:isConnected];
  return 0;
}

NSString *const SSSlaveErrorDomain = @"SSSlaveErrorDomain";

@implementation SSSlave

@synthesize connected;
@synthesize MAC;
@synthesize delegate;

- (id)initWithHost:(NSString *)host
{
  if ((self = [super init])) {
    connected = NO;
    MAC = @"000000000001";
    serverHost = [host copy];
  }
  
  return self;
}

- (void)dealloc 
{  
  [self disconnect];
  [serverHost release];
  [MAC release];
  [super dealloc];
}

- (BOOL)connect:(NSError **)error;
{
  [self disconnect];
  
  PaDeviceIndex output_device_id = 2;
  
  unsigned int output_predelay = 0;
  unsigned int output_predelay_amplitude = 0;
  
  slimaudio_volume_t volume_control = VOLUME_SOFTWARE;

  int keepalive_interval = -1;

  if (slimproto_init(&slimproto) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveInitializationError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to initialize slimproto." forKey:@"debugInfo"]];
    return NO;
  }
  
  if (slimaudio_init(&slimaudio, &slimproto, output_device_id, output_change) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveInitializationError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to initialize slimaudio." forKey:@"debugInfo"]];
    return NO;
  }
  
  slimproto_add_connect_callback(&slimproto, connect_callback, self);
  slimaudio_set_volume_control(&slimaudio, volume_control);
  slimaudio_set_output_predelay(&slimaudio, output_predelay, output_predelay_amplitude);
  
  if (keepalive_interval >= 0) {
    slimaudio_set_keepalive_interval(&slimaudio, keepalive_interval);
  }
  
  if (slimaudio_open(&slimaudio) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveInitializationError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to open slimaudio." forKey:@"debugInfo"]];
    return NO;
  }
  
  if (slimproto_connect(&slimproto, [serverHost cStringUsingEncoding:NSUTF8StringEncoding], port) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveConnectionError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to connect to server." forKey:@"debugInfo"]];
    return NO;
  }
 
  return YES;
}

- (void)disconnect
{
  if (connected) {
    slimaudio_close(&slimaudio);
    slimproto_close(&slimproto);
    slimaudio_destroy(&slimaudio);
    slimproto_destroy(&slimproto);
    connected = NO;
    
    if ([self.delegate respondsToSelector:@selector(slaveDidDisconnect:)]) {
      [(id)self.delegate performSelectorOnMainThread:@selector(slaveDidDisconnect:) withObject:self waitUntilDone:NO];
    }
  }
}

#pragma mark -
#pragma mark Private slimproto handlers

- (void)handleSlimprotoConnect:(bool)isConnected
{
  connected = (BOOL)isConnected;
  
  if (connected) {
    char mac_address[12];
    [MAC getCString:mac_address maxLength:12 encoding:NSUTF8StringEncoding];
    
    if (slimproto_helo(&slimproto, player_type, firmware, mac_address, 0, 0) < 0) {
      NSLog(@"Could not send helo to Squeezebox Server.");
      [self disconnect];
    } else {
      if ([self.delegate respondsToSelector:@selector(slaveDidConnect:)]) {
        [(id)self.delegate performSelectorOnMainThread:@selector(slaveDidConnect:) withObject:self waitUntilDone:NO];
      }
    }
  } else {
    [self disconnect];
  }
}

@end
