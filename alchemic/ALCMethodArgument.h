//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractDependency.h"

@protocol ALCDependency;
@protocol ALCModel;
@class ALCMethodArgument;

NS_ASSUME_NONNULL_BEGIN

#define AcArg(argClass, critieria, ...) [ALCArgument argumentWithClass:[argClass class] model:model criteria:criteria, ## __VA_ARGS__, nil]

@interface ALCMethodArgument : ALCAbstractDependency

@property (nonatomic, assign) int index;

-(instancetype) init NS_UNAVAILABLE;

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END

