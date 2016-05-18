//
//  ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCModelSearchCriteria;
@class ALCClassObjectFactory;
@protocol ALCObjectFactory;
@protocol ALCResolvable;
@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCModel <NSObject>

@property (nonatomic, readonly, strong) NSArray<id<ALCObjectFactory>> *objectFactories;

@property (nonatomic, readonly, strong) NSArray<ALCClassObjectFactory *> *classObjectFactories;

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory withName:(NSString *) name;

-(NSDictionary<NSString *, id<ALCObjectFactory>> *) objectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria;

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName;

-(nullable ALCClassObjectFactory *) classObjectFactoryForClass:(Class) aClass;

-(void) resolveDependencies;

-(void) startSingletons;

@end

NS_ASSUME_NONNULL_END