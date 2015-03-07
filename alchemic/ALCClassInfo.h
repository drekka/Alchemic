//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCClassInfo : NSObject

@property (nonatomic, assign, readonly) Class forClass;

@property (nonatomic, assign) SEL constructor;

@property (nonatomic, strong, readonly) NSArray *injectionPoints;

@property (nonatomic, assign) BOOL isSingleton;

-(instancetype) initWithClass:(Class) forClass;

-(void) addInjectionPoint:(NSString *) injectionPoint;

@end
