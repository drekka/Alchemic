//
//  ALCTypeData.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Simple class containing information about a type.
 */
@interface ALCTypeData : NSObject

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign, nullable) const char *scalarType;

/**
 The class if the type is an object type.
 */
@property (nonatomic, assign, nullable) Class objcClass;

/**
 Any protocols that the class implements.
 */
@property (nonatomic, strong, nullable) NSArray<Protocol *> *objcProtocols;

@end
