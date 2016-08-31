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
 
 @param criteria    The ALCModelSearchCriteria to used when searching the model.
 
 @return The results of the search, mapped to the objectClass type.
 */
+(instancetype) valueSourceWithCriteria:(ALCModelSearchCriteria *) criteria;

@end

NS_ASSUME_NONNULL_END

