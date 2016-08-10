//
//  ALCContext+Internal.h
//  alchemic
//
//  Created by Derek Clarkson on 4/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@class ALCClassObjectFactory;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCContextInternal

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory
                     config:(NSArray *) config;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(Class) returnType
        configAndArgs:(NSArray *) configAndArgs;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
          initializer:(SEL) initializer
                 args:(NSArray *) args;

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
    registerInjection:(Ivar) variable
             withName:(NSString *) name
               ofType:(Class) type
               config:(NSArray *) config;

-(id) objectWithClass:(Class) returnType
       searchCriteria:(NSArray *) criteria;

-(void) setObject:(id) object
   searchCriteria:(NSArray *) criteria;

@end

NS_ASSUME_NONNULL_END
