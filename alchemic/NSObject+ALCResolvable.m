//
//  NSObject+ALCResolvable.m
//  alchemic
//
//  Created by Derek Clarkson on 20/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "NSObject+ALCResolvable.h"

@implementation NSObject (ALCResolvable)

-(void) kvoWatchAvailableInResolvableArray:(NSArray<NSObject<ALCResolvable> *> *) resolvables {
    for (NSObject<ALCResolvable> *resolvable in resolvables) {
        [self kvoWatchAvailable:resolvable];
    }
}

-(void) kvoRemoveWatchAvailableFromResolvableArray:(NSArray<NSObject<ALCResolvable> *> *) resolvables {
    for (NSObject<ALCResolvable> *resolvable in resolvables) {
        [self kvoRemoveWatchAvailable:resolvable];
    }
}

-(void) kvoWatchAvailableInResolvableSet:(NSSet<NSObject<ALCResolvable> *> *) resolvables {
    for (NSObject<ALCResolvable> *resolvable in resolvables) {
        [self kvoWatchAvailable:resolvable];
    }
}

-(void) kvoRemoveWatchAvailableFromResolvableSet:(NSSet<NSObject<ALCResolvable> *> *) resolvables {
    for (NSObject<ALCResolvable> *resolvable in resolvables) {
        [self kvoRemoveWatchAvailable:resolvable];
    }
}

-(void) kvoWatchAvailable:(NSObject<ALCResolvable> *) resolvable {
    [resolvable addObserver:self forKeyPath:@"available" options:0 context:nil];
}

-(void) kvoRemoveWatchAvailable:(NSObject<ALCResolvable> *) resolvable {
    [resolvable removeObserver:self forKeyPath:@"available"];
}

@end
