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

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCValue : ALCType

@property (nonatomic, strong) NSValue *value;

/**
 Factory method for analysing a passed encoding.
 
 @param encoding The encoding to analyse.
 */
+(instancetype) value:(nullable NSValue *) value withEncoding:(const char *) encoding;

@end

NS_ASSUME_NONNULL_END
