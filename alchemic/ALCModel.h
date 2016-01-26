//
//  ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

typedef bool (^ALCObjectFactoryTest) (id<ALCObjectFactory> objectFactory);

@protocol ALCModel <NSObject>

@property (nonatomic, readonly, strong) NSSet<id<ALCObjectFactory>> *objectFactories;

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

-(NSArray<id<ALCObjectFactory>> *) objectFactoriesPassingTest:(ALCObjectFactoryTest) test;

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName;

@end

NS_ASSUME_NONNULL_END