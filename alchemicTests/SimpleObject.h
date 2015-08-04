//
//  SImpleObject.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "AlchemicAware.h"

@interface SimpleObject : NSObject<AlchemicAware>
@property (nonatomic, strong) NSString *aStringProperty;
@property (nonatomic, assign) BOOL stringFactoryWithAStringCalled;
@property (nonatomic, assign, readonly) BOOL didInject;
-(instancetype) initAlternative;
-(instancetype) initWithString:(NSString *) aString;
-(NSString *) stringFactoryMethod;
-(NSString *) stringFactoryMethodUsingAString:(NSString *) aString;
@end
