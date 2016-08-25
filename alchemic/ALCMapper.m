//
//  ALCMapper.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMapper.h"

#import <Alchemic/ALCTypeData.h>

@implementation ALCMapper

-(nullable ALCMapBlock) mapFromType:(ALCTypeData *) fromType toType:(ALCTypeData *) toType {
    ALCType from = fromType.type;
    ALCType to = toType.type;

    switch (from) {

        case ALCTypeObject:
            switch (to) {
                case ALCTypeInt:
                    return [self numberIntToObjcType:toType.scalarType];
                default:
                    return NULL;
            }
            break;

        case ALCTypeInt:
            switch (to) {
                default:
                    return NULL;
            }
            break;

        default:
            return NULL;
    }

}

-(ALCMapBlock) numberIntToObjcType:(const char *) type {
    return ^(ALCMapBlockArgs) {
        NSNumber *nbr = value.nonretainedObjectValue;
        int intNbr = nbr.intValue;
        injector(self, [NSValue value:&intNbr withObjCType:type]);
    };
}

@end
