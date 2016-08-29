//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCValueSource.h>

@class ALCModelSearchCriteria;
@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

/**
 An ALCInjector that sources values from the model using a variety of criteria.
 */
@interface ALCModelValueSource : NSObject<ALCValueSource>

/// The search criteria that will be used to find the object.
@property (nonatomic, strong, readonly) ALCModelSearchCriteria *criteria;

/**
 Unused initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param type The type of the value to be injected.
 @param criteria    The ALCModelSearchCriteria to used when searching the model.

 @return The results of the search, mapped to the objectClass type.
 */
-(instancetype) initWithType:(ALCType *) type
                    criteria:(ALCModelSearchCriteria *) criteria NS_DESIGNATED_INITIALIZER;

/**
 Executes a model search and return the results.

 @param error A pointer to a NSError variable that will be populated if there is an error.
 All returned objects will be fully completed.
 */
-(nullable id) searchResultWithError:(NSError * __autoreleasing _Nullable *) error;

@end

NS_ASSUME_NONNULL_END

