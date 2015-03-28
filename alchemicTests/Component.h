//
//  SingletonObject.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "AlchemicAware.h"
#import "InjectableObject.h"
#import "InjectableProtocol.h"

@interface Component : NSObject<AlchemicAware>

@property(nonatomic, strong) InjectableObject *injObj;
@property(nonatomic, strong) id<InjectableProtocol> injProto;

@end
