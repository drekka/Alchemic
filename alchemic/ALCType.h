//
//  ALCClassInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 21/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

/**
 Holds information about a value.
 */
@interface ALCType : NSObject

@property (nonatomic, assign, readonly) Class typeClass;
@property (nonatomic, strong, readonly) NSSet *typeProtocols;

+(instancetype) typeForInjection:(Ivar) variable inClass:(Class) class;

-(instancetype) initWithClass:(Class) class NS_DESIGNATED_INITIALIZER;

-(void) addProtocol:(Protocol *) protocol;

-(BOOL) typeIsKindOfClass:(Class)aClass;

-(BOOL) typeConformsToProtocol:(Protocol *)aProtocol;


@end
