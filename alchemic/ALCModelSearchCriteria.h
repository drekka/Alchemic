//
//  ALCObjectFactorySelector.h
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCObjectFactory;
@class ALCModelSearchCriteria;

NS_ASSUME_NONNULL_BEGIN

#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

#pragma mark - C wrappers for Swift

@interface ALCModelSearchCriteria : NSObject

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz;

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol;

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name;

@property (nonatomic, strong) ALCModelSearchCriteria *nextSearchCriteria;

-(ALCModelSearchCriteria *) combineWithCriteria:(ALCModelSearchCriteria *) otherCriteria;

-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name;

@end

NS_ASSUME_NONNULL_END