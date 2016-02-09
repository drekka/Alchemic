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

-(Class) objectClass {
    return [_value class];
}

-(bool) resolved {
    return YES;
}

-(instancetype) initWithValue:(id) value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {}

@end
