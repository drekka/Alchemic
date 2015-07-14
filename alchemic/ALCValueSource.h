//
//  ALCValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCDependencyPostProcessor.h"

/**
 Objects that can produce values for dependencies.
 */
@protocol ALCValueSource <NSObject>

@property (nonatomic, strong, nonnull) NSSet<id> *values;

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> __nonnull *) postProcessors;

@end
