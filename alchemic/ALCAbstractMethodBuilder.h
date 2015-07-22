//
//  ALCAbstractMethodBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;
@class ALCMethodRegistrationMacroProcessor;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMethodBuilder : ALCAbstractBuilder

@property (nonatomic, strong, readonly) id<ALCBuilder> parentClassBuilder;
@property (nonatomic, assign, readonly) SEL selector;

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											arguments:(ALCMethodRegistrationMacroProcessor *) arguments NS_DESIGNATED_INITIALIZER;

-(id) invokeMethodOn:(id) target;

@end

NS_ASSUME_NONNULL_END
