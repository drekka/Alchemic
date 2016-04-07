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

@protocol ALCContext <NSObject>

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Registering

-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) clazz;

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... NS_REQUIRES_NIL_TERMINATION;

-(ALCMethodObjectFactory *) objectFactory:(ALCClassObjectFactory *) objectFactory
                            factoryMethod:(SEL) selector
                               returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

-(void) objectFactory:(ALCClassObjectFactory *) parentObjectFactory initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory vaiableInjection:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Registration management

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory
          changedName:(NSString *) oldName
              newName:(NSString *) newName;


@end

NS_ASSUME_NONNULL_END
