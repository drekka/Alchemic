//
//  ALCMacroArgumentProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

@interface ALCMacroArgumentProcessor : NSObject

@property (nonatomic, assign) Class parentClass;

@property (nonatomic, assign, readonly) Class returnType;
@property (nonatomic, assign, readonly) BOOL isClassSelector;
@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSString *variableName;
@property (nonatomic, assign, readonly) Ivar variable;
@property (nonatomic, strong, readonly) NSString *asName;
@property (nonatomic, assign, readonly) BOOL isFactory;
@property (nonatomic, assign, readonly) BOOL isPrimary;

-(instancetype) initWithParentClass:(Class) parentClass;

-(void) addArgument:(id) argument;

-(id<ALCValueSource>) dependencyValueSource;

-(NSArray<id<ALCValueSource>> *) methodValueSources;

/**
 Call after sending all arguments to validate the content sent.
 
 @param parentClass the class that the data is about.
 */
-(void) validate;

@end

NS_ASSUME_NONNULL_END