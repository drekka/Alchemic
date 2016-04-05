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

-(void) resolveWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {}
-(void) resolveDependencyWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack withName:(NSString *) name model:(id<ALCModel>) model {}

-(nullable ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable {
    methodNotImplemented;
    return NULL;
}

-(nullable ALCSimpleBlock) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {
    methodNotImplemented;
    return NULL;
}

@end
