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

/// @name Macros

/**
 @brief Selects factories which return instances of the specified class.
 
 @param className The class to search for.
 */
#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

/**
 @brief Selects factories which return instances which conform to the specified protocol.
 
 @param protocolName The protocol to look for.
 */
#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

/**
 @brief Selects a single factory based on it's unique name.
 
 @param objectName The factory name.
 */
#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Defines and builds search critieria for finding factories within the model.
 */
@interface ALCModelSearchCriteria : NSObject

/// @name Factories

/**
 @brief Builds a search criteria which finds factories which return instances of the specific class.
 
 @param clazz The class to search for.
 
 @return An instance of ALCModelSearchCriteria.
 */
+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz;

/**
 @brief Builds a search criteria which finds factories which return instances which conform to the specific protocol.
 
 @param protocol The protocol to search for.
 
 @return An instance of ALCModelSearchCriteria.
 */
+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol;

/**
 @brief Builds a search criteria which a specific factory based on it's unique name.
 
 @param name The factories unique name.
 
 @return An instance of ALCModelSearchCriteria.
 */
+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name;

/**
 @brief Adds a search criteria to the chain of criteria.
 
 This will pass the new criteria on to any chained criteria until it finds the last one in the chain. Then the new criteria is set as the next one in the chain.
 
 @param criteria The criteria to append.
 */
-(void) appendSearchCriteria:(ALCModelSearchCriteria *) criteria;

/// @name Checking

/**
 @brief Called to decide if a factory passes the current criteria. 
 
 If the current criteria has a nextSearchCriteria value, then it is automatically called as well.
 
 @param valueFactory An instance of ALCObjectFactory to be checked.
 @param name         The unqie model name of that instance.
 
 @return YES if the factory matches the criteria.
 */
-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name;

@end

NS_ASSUME_NONNULL_END