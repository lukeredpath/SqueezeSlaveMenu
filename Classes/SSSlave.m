//
//  SSSlave.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SSSlave.h"

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
  if (isConnected) {
    if (slimproto_helo(p, player_type, firmware, (char*) user_data, 0, 0) < 0) {
      NSLog(@"Could not send helo to Squeezebox Server.");
    }
  } else {
    NSLog(@"Connect callback called, not connected!");
  }
  return 0;
}

NSString *const SSSlaveErrorDomain = @"SSSlaveErrorDomain";

@implementation SSSlave

- (id)init 
{
  if ((self = [super init])) {
    connected = NO;
  }
  
  return self;
}

- (void)dealloc 
{  
  [self disconnect];
  [super dealloc];
}

- (BOOL)connect:(NSError **)error;
{
  [self disconnect];
  
  PaDeviceIndex output_device_id = 2;
  
  unsigned int output_predelay = 0;
  unsigned int output_predelay_amplitude = 0;
  
  slimaudio_volume_t volume_control = VOLUME_SOFTWARE;
  
  char macaddress[6] = { 0, 0, 0, 0, 0, 1 };
  int keepalive_interval = -1;

  char *slimserver_address = "mac-mini.local";

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
  
  slimproto_add_connect_callback(&slimproto, connect_callback, macaddress);
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
  
  if (slimproto_connect(&slimproto, slimserver_address, port) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveConnectionError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to connect to server." forKey:@"debugInfo"]];
    return NO;
  }
  
  connected = YES;
  
  return YES;
}

- (void)disconnect
{
  if (connected) {
    slimaudio_close(&slimaudio);
    slimproto_close(&slimproto);
    slimaudio_destroy(&slimaudio);
    slimproto_destroy(&slimproto);    
  }
}

@end
