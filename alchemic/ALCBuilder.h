//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@class ALCDependency;
@protocol ALCDependencyPostProcessor;
@protocol ALCMacroProcessor;
#import "ALCValidatable.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ALCBuilder <NSObject, ALCValidatable>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) BOOL createOnBoot;

// If the builder is to be regarded as a primary builder.
@property (nonatomic, assign) BOOL primary;

// If the builder is a factory.
@property (nonatomic, assign) BOOL factory;

#pragma mark - Resolving

/**
 Called during model setup to resolve dependencies into a list of candidate objects.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

/**
 Creates the object and puts it into the value if this is not a factory.

 @discussion This does not trigger dependency injection. Use the value property to obtain objects and get them injected.
 @see value
 */
-(id) instantiate;

@property (nonatomic, strong) id value;

@end

NS_ASSUME_NONNULL_END