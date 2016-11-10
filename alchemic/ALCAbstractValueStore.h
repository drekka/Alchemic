//
//  ALCAbstractPropertiesFacade.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCValueStore.h"
#import "ALCValueStoreImplementation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class for classes that can act as facades for various properties systems. For example user defaults or cloud key value stores.
 
 This class provides services to KVO watch properties in extended classes and automatically update the backing storage mechanism and provides subscript based access to data.
 
 It's designed to act as a local copy of the original store which is referred to as the backing store.
 
 Note; If instantiating this class outside of Alchemic, ensure that the alchemicDidInjectDependencies methos is called to finish initializing it and to get defaults loaded.
 
 */
@interface ALCAbstractValueStore : NSObject<ALCValueStore, ALCValueStoreImplementation>

/**
 Override so we can require a call to super if this is overriden.
 */
-(void) observeValueForKeyPath:(nullable NSString *) keyPath
                      ofObject:(nullable id) object
                        change:(nullable NSDictionary<NSKeyValueChangeKey,id> *) change
                       context:(nullable void *) context NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
