//
//  ALCArrayValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCValueSource.h>

@interface ALCArrayValueSource : NSObject<ALCValueSource>

-(instancetype)init NS_UNAVAILABLE;

-(instancetype) initWithValueSources:(NSArray<id<ALCValueSource>> *) sources;

@end
