//
//  ALCAbstractValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractValueSource.h"

#import "ALCInternalMacros.h"
#import "ALCObjectFactory.h"
#import "ALCResolvable.h"
#import "ALCModel.h"
#import "ALCType.h"

@implementation ALCAbstractValueSource

@synthesize type = _type;

-(instancetype) initWithType:(ALCType *) type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

-(nullable ALCValue *) value {
    methodReturningObjectNotImplemented;
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return NO;
}

-(BOOL)referencesTransients {
    return NO;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>)model {}

-(BOOL)isReady {
    return YES;
}

-(NSString *)resolvingDescription {
    return _type.description;
}

@end
