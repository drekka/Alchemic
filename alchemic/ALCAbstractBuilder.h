//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCType;
@class ALCContext;
@class ALCDependency;

#import <Alchemic/ALCBuilder.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

-(instancetype) initWithValueClass:(Class) valueClass
										name:(NSString *) name;

/**
 Called to create the object.
 */
-(id) instantiateObject;

/**
 Called to resolve dependencies after the value has been created.
 */
-(void) injectObjectDependencies:(id) object;

@end

NS_ASSUME_NONNULL_END