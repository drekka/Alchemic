//
//  ALCAbstractMacroProcessor.h
//  
//
//  Created by Derek Clarkson on 17/07/2015.
//
//

@import Foundation;

#import "ALCMacroProcessor.h"
@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMacroProcessor : NSObject<ALCMacroProcessor>

@property (nonatomic, assign, readonly) Class parentClass;

-(instancetype) initWithParentClass:(Class) parentClass;

-(id<ALCValueSource>) valueSourceForMacros:(NSArray *) macros;

@end

NS_ASSUME_NONNULL_END
