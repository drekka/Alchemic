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
@class ALCArg;
#import "ALCAbstractMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodRegistrationMacroProcessor : ALCAbstractMacroProcessor

@property (nonatomic, assign, readonly) Class returnType;
@property (nonatomic, assign, readonly) BOOL isClassSelector;
@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSString *asName;
@property (nonatomic, assign, readonly) BOOL isFactory;
@property (nonatomic, assign, readonly) BOOL isPrimary;

-(instancetype) initWithParentClass:(Class) parentClass selector:(SEL) selector returnType:(Class) returnType NS_DESIGNATED_INITIALIZER;

-(NSArray<ALCArg *> *) methodValueSources;

@end

NS_ASSUME_NONNULL_END