//
//  ALCBuilderType.h
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
 A builder strategy that helps create objects using factory methods.
 */
@interface ALCMethodBuilderType : ALCAbstractMethodBuilderType

/**
 Don't use.

 @parameter initWithClassBuilder: The class builder that references the class that contains the method to be executed.
 */
hideInitializer(initWithType:(Class) valueClass classBuilder:(ALCBuilder *) classBuilder);

/**
 Default initializer.

 @param valueClass   The expected type that the class will return. USed to locate a class builder which is used to do injections into the returned value.
 @param parentClassBuilder The class builder that references the class that contains the method to be executed.
 @param selector     The selector to execute.

 @return An instance of this builder strategy.
 */
-(instancetype) initWithType:(Class) valueClass
          parentClassBuilder:(ALCBuilder *) parentClassBuilder
                    selector:(SEL) selector;

@end

NS_ASSUME_NONNULL_END

