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

@interface ALCType (copying)
-(ALCValue *) withValue:(id) value completion:(nullable ALCSimpleBlock) completion;
@end

/**
 Simple class containing information about a type.
 */
@interface ALCValue : ALCType
@property (nonatomic, strong, readonly) id value;
@property (nonatomic, strong, nullable, readonly) ALCSimpleBlock completion;
@end

NS_ASSUME_NONNULL_END
