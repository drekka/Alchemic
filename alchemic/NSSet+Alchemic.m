//
//  NSSet+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 13/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSSet (Alchemic)

-(NSString *) componentsJoinedByString:(NSString *) delimiter {
    NSArray *components = self.allObjects;
    return [components componentsJoinedByString:delimiter];
}

-(NSString *) componentsJoinedByString:(NSString *) delimiter withTemplate:(NSString *) componentTemplate {
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        [components addObject:[NSString stringWithFormat:componentTemplate, obj]];
    }
    return [components componentsJoinedByString:delimiter];
}

@end

NS_ASSUME_NONNULL_END