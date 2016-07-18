//
//  ALCAbstractConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCAbstractConstantInjector.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCDefs.h>

@implementation ALCAbstractConstantInjector

-(BOOL) isReady {
    return YES;
}

-(Class) objectClass {
    return [self class];
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {}

-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return NO;
}

-(ALCSimpleBlock) injectObject:(id)object {
    methodReturningBlockNotImplemented;
}

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
