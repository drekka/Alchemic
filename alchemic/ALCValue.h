//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCtypeDefs.h>

@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCValue : NSObject

@property (nonatomic, strong, readonly) id value;
@property (nonatomic, strong, nullable, readonly) ALCSimpleBlock completion;

+(ALCValue *) withValue:(id) value
             completion:(nullable ALCSimpleBlock) completion;

@end

NS_ASSUME_NONNULL_END
