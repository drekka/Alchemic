//
//  ALCAbstractConstantValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCAbstractValueSource.h>

@class ALCType;

#define AcString(value) [ALCConstantValueSource valueSourceWithObject:value]
#define AcInt(value) [ALCConstantValueSource valueSourceWithInt:value]

@interface ALCConstantValueSource : ALCAbstractValueSource

-(instancetype) initWithType:(ALCType *) type NS_UNAVAILABLE;

+(instancetype) valueSourceWithObject:(id) object;

+(instancetype) valueSourceWithInt:(int) value;


@end
