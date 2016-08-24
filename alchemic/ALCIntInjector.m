//
//  ALCIntInjector.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCIntInjector.h"

@implementation ALCIntInjector

@synthesize objectClass =_objectClass;
@synthesize ready = _ready;
@synthesize resolvingDescription = _resolvingDescription;
@synthesize allowNilValues = _allowNilValues;

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>)model {}

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable error:(NSError **) error {
    return nil;
}

-(BOOL) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx error:(NSError **) error {
    return NO;
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return NO;
}

@end
