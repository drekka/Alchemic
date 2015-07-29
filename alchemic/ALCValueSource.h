//
//  ALCValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCValidatable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependencyPostProcessor;

/**
 Objects that can produce values for dependencies.
 */
@protocol ALCValueSource <NSObject, ALCValidatable>

-(id) valueForType:(Class) finalType;

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

@end

NS_ASSUME_NONNULL_END