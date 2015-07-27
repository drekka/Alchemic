//
//  ALCAbstractMethodBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@protocol ALCSearchableBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMethodBuilder : ALCAbstractBuilder

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithSelector:(SEL) selector NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<ALCSearchableBuilder> parentClassBuilder;

@property (nonatomic, assign, readonly) SEL selector;

-(id) invokeMethodOn:(id) target;

@end

NS_ASSUME_NONNULL_END
