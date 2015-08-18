//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractMethodBuilder.h"
@class ALCClassBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 Builders an object by calling a method on another objects.
 */
@interface ALCMethodBuilder : ALCAbstractMethodBuilder

/**
 Default initializer.

 @warning Do not use.

 @param parentClassBuilder The class builder that represents the object on which the method will be called.
 @param selector The selector to be called.
 */
-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
                                  selector:(SEL) selector NS_UNAVAILABLE;

/**
 Default initializer.

 @param parentClassBuilder The class builder that represents the object on which the method will be called.
 @param selector The selector to be called.
 @param valueClass The class of the returned object from the method.
 */
-(instancetype) initWithParentBuilder:(ALCClassBuilder *) parentClassBuilder
                             selector:(nonnull SEL)selector
                           valueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
