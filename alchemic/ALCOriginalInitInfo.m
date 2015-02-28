//
//  ALCReplacedInit.m
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCOriginalInitInfo.h"

@implementation ALCOriginalInitInfo

-(instancetype) initWithOriginalClass:(Class) originalClass
                         initSelector:(SEL) initSelector
                              initIMP:(IMP) initIMP
                          withContext:(ALCContext *) context {
    self = [super init];
    if (self) {
        _originalClass = originalClass;
        _initSelector = initSelector;
        _initIMP = initIMP;
        _context = context;
    }
    return self;
}

@end
