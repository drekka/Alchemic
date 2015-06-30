//
//  ALCNameMatcher.h
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCMatcher.h>

@interface ALCNameMatcher : NSObject<ALCMatcher>

+(instancetype) matcherWithName:(NSString *) name;

@end
