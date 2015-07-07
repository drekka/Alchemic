//
//  ALCAbstractClassWithProtocolProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 2/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassWithProtocolClassProcessor.h"
@import ObjectiveC;
#import "ALCAbstractClass.h"

@implementation ALCClassWithProtocolClassProcessor {
    Protocol *_protocol;
    ClassMatchesBlock _matchesBlock;
    Protocol *_abstract;
}

-(instancetype) initWithProtocol:(Protocol *) protocol whenMatches:(ClassMatchesBlock) matchesBlock {
    self = [super init];
    if (self) {
        _protocol = protocol;
        _matchesBlock = matchesBlock;
        _abstract = @protocol(ALCAbstractClass);
    }
    return self;
}

-(void) processClass:(Class) aClass withContext:(ALCContext *)context {
    // Use the runtime call for checking for abstracts because only want to check the current class. Use the class object conforms to protocol because we want to check the entire heirarchy.
    if (!class_conformsToProtocol(aClass, _abstract)
        && [aClass conformsToProtocol:_protocol]) {
        _matchesBlock(context, aClass);
    }
}

@end
