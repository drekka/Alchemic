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

#import "ALCInstance.h"

@implementation ALCNSObjectInitStrategy

+(BOOL) canWrapInit:(ALCInstance *) instance {
    return ! [instance.objectClass isSubclassOfClass:[UIViewController class]];
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
