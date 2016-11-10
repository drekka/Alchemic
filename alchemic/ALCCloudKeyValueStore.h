//
//  ALCCloudKeyValueStore.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCAbstractValueStore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides a thin wrapper and extension point for data stored in Apple's key value cloud storage.
 */

@interface ALCCloudKeyValueStore : ALCAbstractValueStore

@end

NS_ASSUME_NONNULL_END
