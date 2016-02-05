//
//  ALCValueFactorySelector.h
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCValueFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ALCModelSearchCriteria : NSObject

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz;

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol;

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name;

@property (nonatomic, strong, nullable) ALCModelSearchCriteria *nextSearchCriteria;

-(bool) acceptsValueFactory:(id<ALCValueFactory>) valueFactory name:(NSString *) name;

@end

NS_ASSUME_NONNULL_END