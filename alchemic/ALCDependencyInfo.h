//
//  ALCDependencyInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCClassInfo;
#import <objc/runtime.h>

/**
 Container object for information about an injection.
 */
@interface ALCDependencyInfo : NSObject

@property (nonatomic, assign, readonly) Class parentClass;
@property (nonatomic, assign, readonly) Ivar variable;
@property (nonatomic, assign, readonly) Class variableClass;
@property (nonatomic, strong, readonly) NSString *variableTypeEncoding;
@property (nonatomic, assign, readonly) NSArray *variableProtocols;
@property (nonatomic, strong) NSDictionary *targetClassInfoObjects;

-(instancetype) initWithVariable:(Ivar) variable parentClass:(Class) parentClass;

@end
