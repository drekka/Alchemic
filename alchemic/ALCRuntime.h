//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@interface ALCTypeData : NSObject
@property (nonatomic, strong, nullable) NSString *scalarType;
@property (nonatomic, assign, nullable) Class objcClass;
@property (nonatomic, strong, nullable) NSArray<Protocol *> *objcProtocols;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

+(ALCTypeData *) typeDataForIVar:(Ivar) iVar;

+(void)setObject:(id) object variable:(Ivar) variable withValue:(id) value;

@end

NS_ASSUME_NONNULL_END
