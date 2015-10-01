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
@protocol ALCBuilderStorage <NSObject>

/**
 Used when builders are describing themselves.
 */
@property (nonatomic, strong, readonly) NSString *attributeText;

/**
 The object being managed.
 */
@property (nonatomic, strong)id value;

/**
 Return YES if a value is stored.
 */
@property (nonatomic, assign, readonly) BOOL hasValue;

@end
