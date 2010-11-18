//
//  SSSlave.m
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "SSSlave.h"
#import "SSSlaveOutputDevice.h"

bool modify_latency = false;
unsigned int user_latency = 0L;

#pragma mark -

@interface SSSlave ()
- (void)handleSlimprotoConnect:(bool)isConnected;
@end

NSString *const SSSlaveErrorDomain = @"SSSlaveErrorDomain";

@implementation SSSlave

@synthesize connected;
@synthesize macAddress;
@synthesize delegate;

- (id)initWithHost:(NSString *)host MACAddress:(NSString *)MAC outputDevice:(SSSlaveOutputDevice *)device;
{
  if ((self = [super init])) {
    connected = NO;
    macAddress = [MAC copy];
    serverHost = [host copy];
    outputDevice = [device retain];
  }
  
  return self;
}

- (void)dealloc 
{  
  [self disconnect];
  [outputDevice release];
  [serverHost release];
  [macAddress release];
  [super dealloc];
}

int parse_macaddress(char *macaddress, NSString *string) {
  char *ptr;
  int i;
  
  const char *str = [string cStringUsingEncoding:NSASCIIStringEncoding];
  
  for (i=0; i<6; i++) {   
    macaddress[i] = (char) strtol (str, &ptr, 16);
    if (i == 5 && *ptr == '\0')
      return 0;
    if (*ptr != ':')
      return -1;
    
    str = ptr+1;
  } 
  return -1;
}

#pragma mark -
#pragma mark Connecting

- (BOOL)connect:(NSError **)error;
{
  [self disconnect];
  
  DLog(@"Connecting to %@:%d...", serverHost, SLIMPROTOCOL_PORT);
  
  unsigned int output_predelay = 0;
  unsigned int output_predelay_amplitude = 0;
  
  slimaudio_volume_t volume_control = VOLUME_SOFTWARE;

  int keepalive_interval = -1;

  if (slimproto_init(&slimproto) < 0) {
    *error = [NSError errorWithDomain:SSSlaveErrorDomain code:SSSlaveInitializationError userInfo:
        [NSDictionary dictionaryWithObject:@"Failed to initialize slimproto." forKey:@"debugInfo"]];
    return NO;
  }
  
  if (slimaudio_init(&slimaudio, &slimproto, (PaDeviceIndex)outputDevice.index, true) < 0) {
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
  
  if (slimproto_connect(&slimproto, [serverHost cStringUsingEncoding:NSUTF8StringEncoding], SLIMPROTOCOL_PORT) < 0) {
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
#pragma mark Private

- (void)handleSlimprotoConnect:(bool)isConnected
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  connected = (BOOL)isConnected;
  
  if (connected) {
    char mac[6] = { 0, 0, 0, 0, 0, 1 };
    if (macAddress) {
      parse_macaddress(mac, macAddress);
    }
    if (slimproto_helo(&slimproto, PLAYER_TYPE, FIRMWARE_VERSION, mac, 0, 0) < 0) {
      DLog(@"Error: could not send helo to Squeezebox Server.");
      [self disconnect];
    } else {
      DLog(@"Connected as %@.", macAddress);
      if ([self.delegate respondsToSelector:@selector(slaveDidConnect:)]) {
        [(id)self.delegate performSelectorOnMainThread:@selector(slaveDidConnect:) withObject:self waitUntilDone:NO];
      }
    }
  } else {
    DLog(@"Disconnected.");
    [self disconnect];
  }
  
  [pool release];
}

@end

#pragma mark -
#pragma mark Slimproto Callbacks

int connect_callback(slimproto_t *p, bool isConnected, void *user_data) {
  [(SSSlave *)user_data handleSlimprotoConnect:isConnected];
  return 0;
}

#pragma mark -

@implementation SSSlave (AudioDevices)

+ (NSArray *)availableOutputDevices:(NSError **)error;
{
    int i;
    int err;
  
    bool bValidDev = false;
    const PaDeviceInfo *pdi;
    const PaHostApiInfo *info;
    PaDeviceIndex DefaultDevice;
    PaDeviceIndex DeviceCount;
    
    err = Pa_Initialize();
    if (err != paNoError) {
      DLog(@"PortAudio error4: %s Could not open any audio devices.\n", Pa_GetErrorText(err));
    }
    DeviceCount = Pa_GetDeviceCount();
    
    if ( DeviceCount < 0 )
    {
      DLog(@"PortAudio error5: %s\n", Pa_GetErrorText(DeviceCount) );
    }
    DefaultDevice = PA_DEFAULT_DEVICE;
    
    if ( DefaultDevice >= DeviceCount )
    {
      DefaultDevice = Pa_GetDefaultOutputDevice();
    }
    
    if ( DefaultDevice == paNoDevice )
    {
      DLog(@"PortAudio error7: No output devices found.\n" );
    }
  
  NSMutableArray *devices = [NSMutableArray arrayWithCapacity:DeviceCount];

    for ( i = 0; i < DeviceCount; i++ )
    {
      pdi = Pa_GetDeviceInfo( i );
      if ( pdi->name == NULL )
      {
        DLog(@"PortAudio error6: GetDeviceInfo failed.\n" );
        continue;
      }

      info = Pa_GetHostApiInfo ( pdi->hostApi );
      if ( info->name == NULL )
      {
        DLog(@"PortAudio error8: GetHostApiInfo failed.\n" );
        continue;
      }

      if ( pdi->maxOutputChannels >= 2 )
      {
        if ( i == DefaultDevice )
        {
          bValidDev = true;
        }
        SSSlaveOutputDevice *device = [[SSSlaveOutputDevice alloc] initWithIndex:i 
           description:[NSString stringWithCString:pdi->name encoding:NSUTF8StringEncoding]];
        [devices addObject:device];
        [device release];
      }
    }
    
    Pa_Terminate();
    
    if ( !bValidDev )
      DefaultDevice = paNoDevice;
    
  return devices;
}

@end



