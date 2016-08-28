//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCType.h>
#import <Alchemic/ALCTypeDefs.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCValue : ALCType

@property (nonatomic, strong, readonly) NSValue *value;
@property (nonatomic, strong, nullable, readonly) ALCSimpleBlock completion;

+(instancetype) valueWithType:(ALCType *) type
                        value:(NSValue *) value
                   completion:(nullable ALCSimpleBlock) completion;

@end

NS_ASSUME_NONNULL_END
