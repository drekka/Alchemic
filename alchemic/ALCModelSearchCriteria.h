//
//  ALCObjectFactorySelector.h
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Core

@interface ALCModelSearchCriteria : NSObject

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz;

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol;

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name;

@property (nonatomic, strong) ALCModelSearchCriteria *nextSearchCriteria;

-(ALCModelSearchCriteria *) combineWithCriteria:(ALCModelSearchCriteria *) otherCriteria;

-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name;

@end

#pragma mark - C wrappers for Swift

ALCModelSearchCriteria * AcWithClass(Class aClass);

ALCModelSearchCriteria * AcWithProtocol(Protocol *aProtocol);

ALCModelSearchCriteria * AcWithName(NSString *name);

NS_ASSUME_NONNULL_END