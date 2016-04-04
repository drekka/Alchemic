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

NS_ASSUME_NONNULL_BEGIN

@interface ALCArgument : NSObject

@property (nonatomic, strong, readonly) id<ALCDependency> dependency;

+(instancetype) argumentWithClass:(Class) argumentClass model:(id<ALCModel>) model criteria:(id) firstCriteria, ... NS_REQUIRES_NIL_TERMINATION;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithDependency:(id<ALCDependency>) dependency NS_DESIGNATED_INITIALIZER;

@end

ALCArgument * AcArgument(Class argumentClass, id firstCriteria, ...) NS_REQUIRES_NIL_TERMINATION;

NS_ASSUME_NONNULL_END

