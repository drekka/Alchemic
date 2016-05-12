//
//  ALCContext.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCDependency;
@protocol ALCObjectFactory;
@class ALCClassObjectFactory;
@class ALCMethodObjectFactory;
@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

#define AcRegister(...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _configureClassObjectFactory):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactoryConfig:classObjectFactory, ## __VA_ARGS__, nil]; \
}

#define AcInitializer(initializerSelector, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectFactoryInitializer):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory setInitializer:@selector(initializerSelector), ## __VA_ARGS__, nil]; \
}

#define AcMethod(methodType, methodSelector, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerMethodObjectFactory):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory \
                    registerFactoryMethod:@selector(methodSelector) \
                               returnType:[methodType class], ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define AcInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectFactoryDependency):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory registerVariableInjection:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

#define AcGet(returnType, ...) [[Alchemic mainContext] objectWithClass:[returnType class], ## __VA_ARGS__, nil]

#pragma mark -

@protocol ALCContext <NSObject>

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Registering

-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) clazz;

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... NS_REQUIRES_NIL_TERMINATION;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory setInitializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerVariableInjection:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Access point for objects which need to have dependencies injected.

 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.

 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id) object;

#pragma mark - Accessing objects

-(id) objectWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
