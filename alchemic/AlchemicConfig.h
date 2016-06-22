//
//  AlchemicConfig.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

/**
 Class which implement this protocol can configure Alchemic.
 */
@protocol AlchemicConfig <NSObject>

@optional

/**
 Implement this method on any number of classes to perform additional configuration programmatically.

 @param context The Alchemic context. You can perform additional Alchemic configuration by calling methods on this context.
 */
+(void) configureAlchemic:(id<ALCContext>) context;

@end

NS_ASSUME_NONNULL_END
