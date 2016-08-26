//
//  ALCValue+Injection.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue.h>

NS_ASSUME_NONNULL_BEGIN

#define VariableInjectorBlockArgs id obj, Ivar ivar
typedef void (^VariableInjectorBlock)(VariableInjectorBlockArgs);

#define InvocationInjectorBlockArgs NSInvocation *inv, NSInteger idx
typedef void (^InvocationInjectorBlock)(InvocationInjectorBlockArgs);

@interface ALCValue (Injection)

-(nullable VariableInjectorBlock) variableInjector;

-(nullable InvocationInjectorBlock) invocationInjector;

@end

NS_ASSUME_NONNULL_END
