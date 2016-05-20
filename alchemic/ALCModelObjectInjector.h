//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCInjector.h>

@class ALCModelSearchCriteria;
@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

/**
 An ALCInjector that sources values from the model using a variety of criteria.
 */
@interface ALCModelObjectInjector : NSObject<ALCInjector>

/**
 Executes a model search and return the results.
 
 All returned objects will be fully completed.
 */
@property (nonatomic, strong, readonly)id searchResult;

/**
 Unused initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.
 
 @param objectClass The class of the value to be injected.
 @param criteria    The ALCModelSearchCriteria to used when searching the model.
 
 @return The results of the search, mapped to the objectClass type.
 */
-(instancetype) initWithObjectClass:(Class) objectClass
                           criteria:(ALCModelSearchCriteria *) criteria NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

