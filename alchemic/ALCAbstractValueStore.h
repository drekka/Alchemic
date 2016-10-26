//
//  ALCAbstractPropertiesFacade.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCValueStore.h>
#import <Alchemic/ALCValueStoreImplementation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class for classes that can act as facades for various properties systems. For example user defaults or cloud key value stores.
 
 This class provides services to KVO watch properties in extended classes and automatically update the backing storage mechanism and provides subscript based access to data.
 
 It's designed to act as a local copy of the original store which is referred to as the backing store.
 
 */
@interface ALCAbstractValueStore : NSObject<ALCValueStore, ALCValueStoreImplementation>

@end

NS_ASSUME_NONNULL_END
