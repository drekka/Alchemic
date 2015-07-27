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
@protocol ALCSearchableBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMethodBuilder : ALCAbstractBuilder

@property (nonatomic, weak) id<ALCSearchableBuilder> parentClassBuilder;
@property (nonatomic, assign) SEL selector;

-(id) invokeMethodOn:(id) target;

@end

NS_ASSUME_NONNULL_END
