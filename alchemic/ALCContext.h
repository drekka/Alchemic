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

NS_ASSUME_NONNULL_BEGIN

@protocol ALCContext <NSObject>

-(void) start;

-(ALCClassObjectFactory *) registerClass:(Class) clazz;

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory
          changedName:(NSString *) oldName
              newName:(NSString *) newName;

-(ALCMethodObjectFactory *) registerMethod:(SEL) selector
                       parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                                      args:(nullable NSArray<id<ALCDependency>> *) arguments
                                returnType:(Class) returnType;

@end

NS_ASSUME_NONNULL_END
