//
//  ALCMacroArgumentProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCMacroArgumentProcessor : NSObject
@property (nonatomic, assign, readonly) Class returnType;
@property (nonatomic, assign, readonly) BOOL isClassSelector;
@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSString *variableName;
@property (nonatomic, strong, readonly) NSString *asName;
@property (nonatomic, assign, readonly) BOOL isFactory;
@property (nonatomic, assign, readonly) BOOL isPrimary;
@property (nonatomic, strong, readonly) id constantValue;
@property (nonatomic, strong, readonly) NSSet<id<ALCModelSearchExpression>> *searchExpressions;

-(void) processArgument:(id) argument;

/**
 When dealing with method arguments, returns the relevant sarch expressions for the argument at the index.
 
 @param index the index of the method argument. Remember this is 2 based because indexes 0 and 1 are the object and selectors of the method.
 */
-(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsAtIndex:(NSUInteger) index;

/**
 Call after sending all arguments to validate the content sent.
 
 @param parentClass the class that the data is about.
 */
-(void) validateWithClass:(Class) parentClass;

@end

NS_ASSUME_NONNULL_END