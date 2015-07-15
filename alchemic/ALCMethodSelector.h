//
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCMacroArgument.h>

@interface ALCMethodSelector : NSObject<ALCMacroArgument>

@property(nonatomic, assign, readonly) SEL methodSelector;

+(instancetype) methodSelector:(SEL) methodSelector;

@end
