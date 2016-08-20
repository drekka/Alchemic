//
//  ALCAbstractConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractConstantInjector.h"

#import "ALCInternalMacros.h"
#import "ALCDefs.h"

@implementation ALCAbstractConstantInjector

@synthesize allowNilValues = _allowNilValues;

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

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable error:(NSError **) error {
    methodReturningBlockNotImplemented;
}

-(BOOL) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx error:(NSError **) error {
    methodReturningBooleanNotImplemented;
}

-(ALCSimpleBlock) completion {
    return NULL;
}

@end
