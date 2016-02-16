//
//  ALCConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCConstantValue.h"

@implementation ALCConstantValue {
    id _value;
}

-(id) object {
    return _value;
}

-(bool) ready {
    return YES;
}

-(Class) objectClass {
    return [_value class];
}

-(instancetype) initWithValue:(id) value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack model:(id<ALCModel>) model {}

@end
