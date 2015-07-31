//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@class ALCDependency;
@protocol ALCDependencyPostProcessor;
@class ALCMacroProcessor;
NS_ASSUME_NONNULL_BEGIN

@protocol ALCBuilder <NSObject>

#pragma mark - Settings

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign, readonly) BOOL createOnBoot;

// If the builder is to be regarded as a primary builder.
@property (nonatomic, assign, readonly) BOOL primary;

// If the builder is a factory.
@property (nonatomic, assign, readonly) BOOL factory;

#pragma mark - Configuring

@property (nonatomic, strong, readonly) ALCMacroProcessor *macroProcessor;

-(void) configure;

#pragma mark - Resolving

/**
 Called during model setup to resolve dependencies into a list of candidate objects.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

/**
 Used to inject dependencies on an abitary object.
 */
-(void) injectValueDependencies:(id) value;

@property (nonatomic, strong) id value;

@end

NS_ASSUME_NONNULL_END