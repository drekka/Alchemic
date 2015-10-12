//
//  ALCInitializerBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCAbstractMethodBuilderType.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A builder strategy that helps create objects using class initializers.
 */
@interface ALCInitializerBuilderType : ALCAbstractMethodBuilderType

/**
 Don't use.

 - parameter initWithClassBuilder: The class builder that define the class to be created.
 */
hideInitializer(initWithType:(Class) valueClass classBuilder:(ALCBuilder *) classBuilder);

/**
 Default initializer.

 @param classBuilder The class builder that defines the class to be created.
 @param initializer  The initializer selector to call to create the class.

 @return An instance of the builder strategy.
 */
-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                         initializer:(SEL) initializer;

@end

NS_ASSUME_NONNULL_END
