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
-(instancetype) init;
@end

@interface ClassWithString:NSObject
-(instancetype) initWithString:(NSString *) aString;
@end

@interface SingletonWithAcMethod:NSObject
-(instancetype) createSingletonWithString:(NSString *) aString;
@end

@interface SingletonWithName:NSObject
@end

@interface SingletonWithInjection:NSObject
@end

@interface Template:NSObject
@end

@protocol PrimaryProtocol
@end

@interface HiddenSingleton:NSObject<PrimaryProtocol>
@end

@interface PrimarySingleton:NSObject<PrimaryProtocol>
@end

@interface Refereence:NSObject
@end

@interface NillableReference:NSObject
@end

@interface WeakReference:NSObject
@end

@interface TransientReference:NSObject
@end
