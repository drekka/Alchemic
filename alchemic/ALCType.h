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

@property (nonatomic, assign) Class __nonnull typeClass;

@property (nonatomic, strong, readonly, nonnull) NSSet<Protocol *> *typeProtocols;

+(nonnull instancetype) typeForInjection:(Ivar __nonnull) variable inClass:(Class __nonnull) class;

+(nonnull instancetype) typeForClass:(Class __nonnull) class;

-(void) addProtocol:(Protocol __nonnull *) protocol;

-(BOOL) typeIsKindOfClass:(Class __nonnull) aClass;

-(BOOL) typeConformsToProtocol:(Protocol __nonnull *) aProtocol;


@end
