//
//  ALCInjectorFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCInjectorFactory.h"

#import <Alchemic/ALCTypeData.h>

@implementation ALCInjectorFactory

-(nullable ALCInjectorBlock) injectorForIvar:(Ivar) ivar type:(ALCTypeData *) type {
    switch (type.type) {
        case ALCTypeInt:
            return [self variableInjectorForIntIvar:ivar];
            break;
        default:
            return NULL;
    }
}

-(ALCInjectorBlock) variableInjectorForIntIvar:(Ivar) ivar {
    return ^(ALCInjectorBlockArgs) {

        // Convert back to an int.
        int intValue;
        [value getValue:&intValue];

        // Set the variable.
        CFTypeRef objRef = CFBridgingRetain(object);
        int *ivarPtr = (int *) ((uint8_t *) objRef + ivar_getOffset(ivar));
        *ivarPtr = intValue;
        CFBridgingRelease(objRef);
    };
}

@end
