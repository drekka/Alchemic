//
//  ALCObjectStorage.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Manages the storage of the objects that the builder supplies.
 */
@protocol ALCValueStorage <NSObject>


/**
 The object being managed.
 */
@property (nonatomic, strong)id value;

/**
 Return YES if a value is stored.
 */
@property (nonatomic, assign, readonly) BOOL hasValue;

/**
 Returns YES if the storage has a value available.
 
 @discussion Available is regarded as slightly different to hasValue and is used when deciding if a builder is available. Available means that the storage can be used regardless of whether it has a value or not. Factory storage will not ever have a value, but is available, where as External storage is not available unless it has a value.
 */
@property (nonatomic, assign, readonly) BOOL available;

@end
