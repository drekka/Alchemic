//
//  ALCDependencyStackItem.m
//  Alchemic
//
//  Created by Derek Clarkson on 10/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCDependencyStackItem.h"
#import "ALCObjectFactory.h"

@implementation ALCDependencyStackItem {
    NSString *_description;
}

@synthesize objectFactory = _objectFactory;

-(instancetype) initWithObjectFactory:(id<ALCObjectFactory>) objectFactory description:(NSString *) description {
    self = [super init];
    if (self) {
        _objectFactory = objectFactory;
        _description = description;
    }
    return self;
}

-(BOOL) isEqual:(id) object {
    if (object == self) {
        return YES;
    }
    return object != nil
    && [object isKindOfClass:[ALCDependencyStackItem class]]
    && ((ALCDependencyStackItem *) object).objectFactory == _objectFactory;
}

-(NSUInteger)hash {
    return [_objectFactory hash];
}

-(NSString *)description {
    return _description;
}

@end
