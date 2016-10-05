//
//  ALCAbstractConstantValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCValueSource;

id<ALCValueSource> AcNil(void);

id<ALCValueSource> AcString(NSString *value);
id<ALCValueSource> AcObject(id value);

id<ALCValueSource> AcBool(BOOL value);

id<ALCValueSource> AcChar(char value);
id<ALCValueSource> AcUnsignedChar(unsigned char value);
id<ALCValueSource> AcCString(const char *value);

id<ALCValueSource> AcDouble(double value);
id<ALCValueSource> AcFloat(float value);

id<ALCValueSource> AcInt(int value);
id<ALCValueSource> AcLong(long value);
id<ALCValueSource> AcLongLong(long long value);
id<ALCValueSource> AcShort(short value);

id<ALCValueSource> AcUnsignedInt(unsigned int value);
id<ALCValueSource> AcUnsignedLong(unsigned long value);
id<ALCValueSource> AcUnsignedLongLong(unsigned long long value);
id<ALCValueSource> AcUnsignedShort(unsigned short value);

id<ALCValueSource> AcSize(float width, float height);
id<ALCValueSource> AcPoint(float x, float y);
id<ALCValueSource> AcRect(float x, float y, float width, float height);

NS_ASSUME_NONNULL_END
