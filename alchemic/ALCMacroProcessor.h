//
//  ALCMethodArgMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCValueSource;

@interface ALCMacroProcessor : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *valueSourceMacros;

@property (nonatomic, assign, readonly) Class parentClass;

-(instancetype) initWithParentClass:(Class) parentClass;

-(void) addArgument:(id) argument;

-(id<ALCValueSource>) valueSource;

-(void) validate;

@end
