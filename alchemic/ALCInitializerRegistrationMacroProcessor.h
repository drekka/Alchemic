//
//  ALCInitializerRegistrationMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@protocol ALCValueSource;
@class ALCArg;
#import "ALCAbstractMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCInitializerRegistrationMacroProcessor : ALCAbstractMacroProcessor

@property (nonatomic, assign, readonly) SEL initializer;

-(instancetype) initWithParentClass:(Class) parentClass initializer:(SEL) initializer NS_DESIGNATED_INITIALIZER;

-(NSArray<ALCArg *> *) methodValueSources;

@end

NS_ASSUME_NONNULL_END