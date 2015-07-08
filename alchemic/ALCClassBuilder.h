//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractBuilder.h"
#import <Alchemic/ALCInitStrategy.h>

@interface ALCClassBuilder : ALCAbstractBuilder

#pragma mark - Setting up

-(void) addInjectionPoint:(NSString __nonnull *) inj withQualifiers:(NSSet __nonnull *) qualifiers;

-(void) addInitStrategy:(id<ALCInitStrategy> __nonnull) initialisationStrategy;

@end
