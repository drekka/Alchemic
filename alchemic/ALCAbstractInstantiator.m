//
//  ALCClassInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInstantiator.h"

@implementation ALCAbstractInstantiator 

@synthesize whenAvailable = _whenAvailable;

-(void) nowAvailable {
    if (self.whenAvailable != NULL) {
        self.whenAvailable(self);
        self.whenAvailable = NULL;
    }
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack{
    [self doesNotRecognizeSelector:_cmd];
}

-(NSString *) builderName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id) instantiateWithClassBuilder:(id)classBuilder arguments:(NSArray *)arguments {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString *)attributeText {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
