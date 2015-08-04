//
//  ALCAbstractMethodBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMethodBuilder : ALCAbstractBuilder

@property (nonatomic, strong, readonly) NSInvocation *inv;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) id<ALCBuilder> parentClassBuilder;

@property (nonatomic, assign, readonly) SEL selector;

-(id) invokeMethodOn:(id) target;

@end

NS_ASSUME_NONNULL_END
