//
//  SingletonObject.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "SingletonObject.h"
#import "Alchemic.h"
#import "InjectableObject.h"
#import "InjectableProtocol.h"

@implementation SingletonObject {
    id _idObj;
    InjectableObject *_injObj;
    id<InjectableProtocol> _injProto;
    NSObject<InjectableProtocol> *_injObjProto;
}

registerSingleton();
inject(@"_injObj", @"_injProto", @"_injObjProto", @"_idObj")

@end
