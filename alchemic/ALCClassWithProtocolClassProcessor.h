//
//  ALCAbstractClassWithProtocolProcessor.h
//  alchemic
//
//  Created by Derek Clarkson on 2/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCClassProcessor.h"

#define classMatchesBlockArgs ALCContext *alcContext, Class class
typedef void(^ClassMatchesBlock)(classMatchesBlockArgs);

@interface ALCClassWithProtocolClassProcessor : NSObject<ALCClassProcessor>

-(instancetype) initWithProtocol:(Protocol *) protocol whenMatches:(ClassMatchesBlock) matchesBlock;

@end
