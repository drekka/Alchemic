//
//  FakeUIApplicationDelegate.m
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Alchemic;

#import "FakeUIApplicationDelegate.h"

@class Networking;

@implementation FakeUIApplicationDelegate {
    Networking *_networking;
}

AcInject(_networking)

@end
