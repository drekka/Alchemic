//
//  ALCDependencyRef.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCAbstractDependency.h"

@protocol ALCInjection;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependency;

@interface ALCVariableDependency : ALCAbstractDependency

-(instancetype)initWithInjection:(id<ALCDependency>)injection NS_UNAVAILABLE;

+(instancetype) variableDependencyWithInjection:(id<ALCInjection>) injection
                                       intoIvar:(Ivar) ivar
                                           name:(NSString *) name;

@end

NS_ASSUME_NONNULL_END