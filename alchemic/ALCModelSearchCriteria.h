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

#define AcClass(className) ac_class([className class])

#define AcProtocol(protocolName) ac_protocol(@protocol(protocolName))

#define AcName(objectName) ac_name(objectName)

#pragma mark - C wrappers for Swift

ALCModelSearchCriteria * ac_class(Class aClass);

ALCModelSearchCriteria * ac_protocol(Protocol *aProtocol);

ALCModelSearchCriteria * ac_name(NSString *name);

@interface ALCModelSearchCriteria : NSObject

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz;

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol;

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name;

@property (nonatomic, strong) ALCModelSearchCriteria *nextSearchCriteria;

-(ALCModelSearchCriteria *) combineWithCriteria:(ALCModelSearchCriteria *) otherCriteria;

-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name;

@end

NS_ASSUME_NONNULL_END