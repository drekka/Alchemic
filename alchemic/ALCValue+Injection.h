//
//  ALCValue+Injection.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue.h>

NS_ASSUME_NONNULL_BEGIN

#define ALCVariableInjectorBlockArgs id obj, Ivar ivar
typedef void (^ALCVariableInjectorBlock)(ALCVariableInjectorBlockArgs);

#define ALCInvocationInjectorBlockArgs NSInvocation *inv, NSInteger idx
typedef void (^ALCInvocationInjectorBlock)(ALCInvocationInjectorBlockArgs);

@interface ALCValue (Injection)

-(nullable ALCVariableInjectorBlock) variableInjector;

-(nullable ALCInvocationInjectorBlock) invocationInjector;

@end

NS_ASSUME_NONNULL_END
