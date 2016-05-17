//
//  SingletonA.m
//  Alchemic
//
//  Created by Derek Clarkson on 8/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "Networking.h"
#import "HTTPServer.h"

#import <Alchemic/Alchemic.h>

@implementation Networking

AcRegister(AcFactoryName(@"networking"))
AcInject(ui)

AcMethod(HTTPServer, createHttpServer, AcFactoryName(@"HTTPServer"))
-(HTTPServer *) createHttpServer {
    return [[HTTPServer alloc] init];
}

@end
