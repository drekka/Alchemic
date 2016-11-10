//
//  ALCArrayValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractValueSource.h"

@class ALCType;
@protocol ALCValueSource;

@interface ALCArrayValueSource : ALCAbstractValueSource

-(instancetype)initWithType:(ALCType *)type NS_UNAVAILABLE;

+(instancetype) valueSourceWithValueSources:(NSArray<id<ALCValueSource>> *) sources;

@end
