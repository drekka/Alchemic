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
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCBuilder <NSObject, ALCResolvable>

#pragma mark - Settings

@property (nonatomic, strong, readonly) Class valueClass;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign, readonly) BOOL createOnBoot;

// If the builder is to be regarded as a primary builder.
@property (nonatomic, assign, readonly) BOOL primary;

// If the builder is a factory.
@property (nonatomic, assign, readonly) BOOL factory;

#pragma mark - Configuring

@property (nonatomic, strong, readonly) ALCMacroProcessor *macroProcessor;

-(void) configure;

/**
 Creates the object and puts it into the value if this is not a factory.

 @discussion This does not trigger dependency injection. Use the value property to obtain objects and get them injected.
 @see value
 */
-(id) instantiate;

/**
 Used to inject dependencies after the value has been created.
 */
-(void) injectValueDependencies:(id) value;


@property (nonatomic, strong) id value;

@end

NS_ASSUME_NONNULL_END