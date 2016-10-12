//
//  Model.m
//  Alchemic
//
//  Created by Derek Clarkson on 11/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Alchemic;
#import "Model.h"

@implementation Singleton : NSObject
AcRegister()
@end

@implementation SingletonWithInit:NSObject
AcInitializer(initWithString:, AcString(@"abc"))
-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _aString = aString;
    }
    return self;
}
@end

@implementation ClassWithString:NSObject
-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _aString = aString;
    }
    return self;
}
@end

@implementation SingletonWithAcMethod:NSObject
AcMethod(ClassWithString, createSingletonWithString:, AcString(@"abc"), AcFactoryName(@"acMethod"))
-(ClassWithString *) createSingletonWithString:(NSString *) aString{
    return [[ClassWithString alloc] initWithString:aString];
}
@end

@implementation SingletonWithName:NSObject
AcRegister(AcFactoryname(@"singleton"))
@end

@implementation SingletonWithInjection:NSObject
AcInject("singleton")
AcInject("aInt", AcInt(5))
@end

@implementation Template:NSObject
static int counter;
AcRegister(AcTemplate)
-(instancetype init)
@end

@protocol PrimaryProtocol
@end

@implementation HiddenSingleton:NSObject<PrimaryProtocol>
@end

@implementation PrimarySingleton:NSObject<PrimaryProtocol>
@end

@implementation Reference:NSObject
@end

@implementation NillableReference:NSObject
@end

@implementation WeakReference:NSObject
@end

@implementation TransientReference:NSObject
@end

@implementation SingletonWithTransient:NSObject
@property (nonatomic, strong, readonly) TransientReference *transientDep;
@end

@implementation SingletonWithAcMethodAcArg:NSObject
-(ClassWithString *) createSingletonWithString:(NSString *) aString;
@end

@implementation EnableSpecialFeatures : NSObject
@end

@implementation Injections : NSObject
@end
