//
//  ALCAbstractObjectGenerator.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;

#import "ALCAbstractObjectGenerator.h"
#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectGenerator {
    Class _objectClass;
}

-(id) object {
    return nil;
}

-(Class) objectClass {
    return _objectClass;
}

-(NSString *) defaultName {
    return NSStringFromClass(self.objectClass);
}

-(NSString *) descriptionAttributes {
    return self.defaultName;
}

-(NSString *) description {

    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendString:self.descriptionAttributes];

    if ([_objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }
    
    return description;
}

-(BOOL) ready {
    return YES;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {}


@end

NS_ASSUME_NONNULL_END
