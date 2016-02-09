//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

+(nullable Class) classForIVar:(Ivar) ivar;

@end

NS_ASSUME_NONNULL_END
