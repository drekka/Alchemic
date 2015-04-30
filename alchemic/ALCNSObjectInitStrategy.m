//
//  ALCSimpleInitWrapper.m
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNSObjectInitStrategy.h"

@import UIKit;
@import ObjectiveC;

#import "ALCInternal.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCContext.h"
#import "Alchemic.h"

@implementation ALCNSObjectInitStrategy

+(BOOL) canWrapInit:(ALCInstance *) instance {
    return ! [ALCRuntime class:instance.forClass extends:[UIViewController class]];
}

-(SEL) initSelector {
    return @selector(init);
}

-(SEL) replacementInitSelector {
    return @selector(initReplacement);
}

-(instancetype) initReplacement {
    initLogic(init,,);
}

@end
