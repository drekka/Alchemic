//
//  AnotherThing.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "AnotherThing.h"

@implementation AnotherThing

-(instancetype) initWithTopThing:(TopThing *) aTopThing {
    self = [super init];
    if (self) {
        self.topThing = aTopThing;
    }
    return self;
}

@end
