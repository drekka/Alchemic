//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"

@implementation ALCDependency {
    ALCModelSearchCriteria *_criteria;
}

@synthesize value = _value;
@synthesize valueClass = _valueClass;
@synthesize resolved = _resolved;

-(instancetype) initWithCriteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _criteria = criteria;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCValueFactory>> *)resolvingStack model:(id<ALCModel>)model {

}

@end
