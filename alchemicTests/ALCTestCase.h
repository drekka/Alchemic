//
//  ALCTestCase.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

@class ALCContext;
@class ALCClassBuilder;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCTestCase : XCTestCase

@property (nonatomic, strong, readonly, nullable) ALCContext *context;
@property (nonatomic, strong, readonly, nullable) id mockContext;

-(void) setupMockContext;
-(void) setupRealContext;

-(void) startContextWithClasses:(NSArray<Class> *) classes;

-(ALCClassBuilder *) simpleBuilderForClass:(Class) aClass;
-(ALCClassBuilder *) externalBuilderForClass:(Class) aClass;

-(void) stubMockContextToReturnBuilders:(NSArray<id<ALCBuilder>> *) builders;

-(void) configureAndResolveBuilder:(id<ALCBuilder>) builder;

@end

NS_ASSUME_NONNULL_END