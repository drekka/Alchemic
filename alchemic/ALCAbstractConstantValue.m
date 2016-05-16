//
//  ALCAbstractConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractConstantValue.h"

#import "ALCInternalMacros.h"

@implementation ALCAbstractConstantValue

-(BOOL) ready {
    return YES;
}

-(Class) objectClass {
    return NULL;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {}

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable {
    methodReturningBlockNotImplemented;
}

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {
    methodNotImplemented;
}

-(ALCSimpleBlock) completion {
    return NULL;
}

@end
