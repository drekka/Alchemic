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

-(nullable void (^)(id origValue)) mapFromType:(ALCTypeData *) fromType
                            toType:(ALCTypeData *) toType
                          injector:(void (^)(id obj, void *value)) injector {
    
    -(BOOL) canMap:(ALCTypeData *) fromType toType:(ALCTypeData *) toType {
        
        ALCType from = fromType.type;
        ALCType to = toType.type;
        
        switch (from) {
                
            case ALCTypeObject:
                switch (to) {
                    case ALCTypeInt:
                        return [self numberToInt];
                    default:
                        return NO;
                }
                break;
                
            case ALCTypeInt:
                switch (to) {
                    case ALCTypeInt:
                        return YES;
                    default:
                        return NO;
                }
                break;
            default:
                return NO;
        }
    }
    
    -(void (^)(id origValue, void (^injectBlock)(id obj, void *value))) numberToInt {
        return ^(id origValue, void (^injectBlock)(id obj, void *value)) {
            NSNumber *nbr = origValue;
            int intNbr = nbr.intValue;
            injectBlock(self, &intNbr);
        };
    }
    
    @end
