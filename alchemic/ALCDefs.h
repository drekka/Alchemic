//
//  ALCDefs.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

typedef void (^ALCSimpleBlock) (void);

#define ALCObjectCompletionArgs id object
typedef void (^ALCObjectCompletion) (ALCObjectCompletionArgs);

FOUNDATION_EXPORT NSString *AlchemicDidCreateObject;
FOUNDATION_EXPORT NSString *AlchemicDidCreateObjectUserInfoObject;
FOUNDATION_EXPORT NSString *AlchemicDidFinishStarting;

