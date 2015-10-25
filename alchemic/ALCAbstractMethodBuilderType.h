//
//  ALCAbstractMethodBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCDependency;
#import "ALCBuilderType.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract builder type for strategies that create objects using methods.
 */
@interface ALCAbstractMethodBuilderType : NSObject<ALCBuilderType>

/**
 The ALCBuilder that will be used to access the class information about the class that contains the method to be executed.
 */
@property (nonatomic, strong, readonly) ALCBuilder *classBuilder;

/**
 Used by derived classes to access a list of the values required for the method.
 */
@property (nonatomic, strong, readonly) NSArray<id> *argumentValues;

hideInitializer(init);

/**
 Default initializer.

 @param classBuilder The class builder for the class that contains the method to be executed.

 @return An instance of this builder type.
 */
-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder;

@end

NS_ASSUME_NONNULL_END

