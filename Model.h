//
//  Model.h
//  Alchemic
//
//  Created by Derek Clarkson on 11/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
@end

@interface SingletonWithInit:NSObject
@property (nonatomic, strong, readonly) NSString *aString;
-(instancetype) initWithString:(NSString *) aString;
@end

@interface ClassWithString:NSObject
@property (nonatomic, strong, readonly) NSString *aString;
-(instancetype) initWithString:(NSString *) aString;
@end

@interface SingletonWithAcMethod:NSObject
-(ClassWithString *) createSingletonWithString:(NSString *) aString;
@end

@interface SingletonWithName:NSObject
@end

@interface SingletonWithInjection:NSObject
@property (nonatomic, strong, readonly) Singleton *singleton;
@property (nonatomic, assign, readonly) int aInt;
@end

@interface Template:NSObject
@property (nonatomic, assign, readonly) int counter;
@end

@protocol PrimaryProtocol
@end

@interface HiddenSingleton:NSObject<PrimaryProtocol>
@end

@interface PrimarySingleton:NSObject<PrimaryProtocol>
@end

@interface Reference:NSObject
@end

@interface NillableReference:NSObject
@end

@interface WeakReference:NSObject
@end

@interface TransientReference:NSObject
@end

@interface SingletonWithTransient:NSObject
@property (nonatomic, strong, readonly) TransientReference *transientDep;
@end

@interface SingletonWithAcMethodAcArg:NSObject
-(ClassWithString *) createSingletonWithString:(NSString *) aString;
@end

@interface EnableSpecialFeatures : NSObject
@end

@interface Injections : NSObject
@end

