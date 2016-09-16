//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCAbstractType.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCtypeDefs.h>

@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCValue : ALCAbstractType

@property (nonatomic, strong, readonly) id valueAsObject;
@property (nonatomic, strong, readonly) NSArray *valueAsArray;
@property (nonatomic, strong, readonly) NSValue *valueAsScalar;
@property (nonatomic, strong, nullable, readonly) ALCSimpleBlock completion;

+(ALCValue *) withValue:(id) value
             completion:(nullable ALCSimpleBlock) completion;

@end

NS_ASSUME_NONNULL_END
