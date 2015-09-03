//
//  ALCClassInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassInstantiator.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCClassBuilder.h"

@implementation ALCClassInstantiator {
    Class _objectClass;
}

hideInitializerImpl(init)

-(instancetype) initWithClass:(Class) aClass {
    self = [super init];
    if (self) {
        _objectClass = aClass;
    }
    return self;
}

-(NSString *) builderName {
    return NSStringFromClass(_objectClass);
}

-(id) instantiateWithClassBuilder:(ALCClassBuilder *) classBuilder arguments:(NSArray *) arguments {
    STLog(_objectClass, @"Creating a %@", NSStringFromClass(_objectClass));
    id object = [[_objectClass alloc] init];
    [classBuilder injectDependencies:object];
    return object;
}

-(NSString *)attributeText {
    return @", class builder";
}

@end
