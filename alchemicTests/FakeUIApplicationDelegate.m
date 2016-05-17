//
//  FakeUIApplicationDelegate.m
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

#import "FakeUIApplicationDelegate.h"

#import "Networking.h"

@implementation FakeUIApplicationDelegate {
    Networking *_networking;
}

AcInject(_networking)

@end
