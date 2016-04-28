//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCDependency;
@protocol ALCModel;
@class ALCArgument;

NS_ASSUME_NONNULL_BEGIN

ALCArgument * AcArgument(Class argumentClass, id firstCriteria, ...) NS_REQUIRES_NIL_TERMINATION;

@interface ALCArgument : NSObject

@property (nonatomic, strong, readonly) id<ALCDependency> dependency;

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END

