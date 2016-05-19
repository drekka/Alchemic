//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 21/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCDefs.h"
#import "ALCResolvable.h"

@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Dependencies define the the values that ALCInjector instances need to perform injections.
 */
@protocol ALCDependency <ALCResolvable>

/**
 The name of the dependency for displaying in resolving stacks.
 */
@property (nonatomic, strong, readonly) NSString *stackName;

/**
 Single access point for triggering injects.
 
 @param object The object to inject. Usually a object or NSInvocation.
 
 @return A block which performs any required completions as a result of the injection.
 */
-(ALCSimpleBlock) injectObject:(id) object;

@end

NS_ASSUME_NONNULL_END
