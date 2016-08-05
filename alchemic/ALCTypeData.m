//
//  ALCTypeData.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCTypeData.h"

@implementation ALCTypeData

-(NSString *) description {
    if (self.scalarType) {
        return [NSString stringWithFormat:@"Scalar %s", self.scalarType];
    } else {
        NSString *className = self.objcClass ? NSStringFromClass((Class) self.objcClass) : @"";
        NSMutableArray<NSString *> *protocols = [[NSMutableArray alloc] init];
        for (Protocol *protocol in self.objcProtocols) {
            [protocols addObject:NSStringFromProtocol(protocol)];
        }
        return [NSString stringWithFormat:@"%@<%@>", className, [protocols componentsJoinedByString:@","]];
    }
}

@end
