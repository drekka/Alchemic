//
//  NSMutableArray+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 27/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSMutableArray+Alchemic.h"

#import "ALCResolvable.h"
#import "ALCModel.h"
#import "ALCObjectGenerator.h"

@implementation NSMutableArray (Alchemic)

-(void) resolve:(id<ALCObjectGenerator>) objectGenerator
          model:(id<ALCModel>) model {
    [self resolve:objectGenerator resolvableName:objectGenerator.defaultName model:model];
}

-(void) resolve:(id<ALCResolvable>) resolvable
 resolvableName:(NSString *) resolvableName
          model:(id<ALCModel>) model {
    [self addObject:resolvableName];
    [resolvable resolveWithStack:self model:model];
    [self removeLastObject];
}


@end
