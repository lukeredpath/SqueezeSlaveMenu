//
//  SSSlave.h
//  SqueezeSlaveMenu
//
//  Created by Luke Redpath on 16/11/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSSlaveErrorDomain;

typedef enum {
  SSSlaveUnknownError = 0
} SSSlaveErrorCode;

@interface SSSlave : NSObject {
@private
    
}
- (BOOL)connect:(NSError **)error;
@end
