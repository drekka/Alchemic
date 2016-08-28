//
//  ALCValue+ALCValue_Mapping.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue.h>

@class ALCType;

NS_ASSUME_NONNULL_BEGIN

@interface ALCValue (Mapping)

/**
 Maps the current value to the type specified by the toValue. 

 This method will convert the current value and set it as the value of the toValue instance. If a mapping is not possible then an error will be generated.
 
 @param toValue The ALCValue instance containing the type information we want to map to.
 @param error A pointer to a NSError variable which will be populated if a mapping cannot be done.
 @return YES if a mapping occured.
 */
-(nullable ALCValue *) mapTo:(ALCType *) toType error:(NSError * _Nullable *) error;

@end

NS_ASSUME_NONNULL_END
