//
//  ALCValue+Injection.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCType.h>
#import <Alchemic/ALCValue.h>

NS_ASSUME_NONNULL_BEGIN

#define ALCVariableInjectorBlockArgs id obj, ALCType *type, Ivar ivar, NSError **error
typedef BOOL (^ALCVariableInjectorBlock)(ALCVariableInjectorBlockArgs);

#define ALCInvocationInjectorBlockArgs NSInvocation *inv, ALCType *type, NSInteger idx, NSError **error
typedef BOOL (^ALCInvocationInjectorBlock)(ALCInvocationInjectorBlockArgs);

@interface ALCValue (Injection)
-(nullable ALCVariableInjectorBlock) variableInjectorForType:(ALCType *) type;
-(nullable ALCInvocationInjectorBlock) invocationInjectorForType:(ALCType *) type;
@end

NS_ASSUME_NONNULL_END
