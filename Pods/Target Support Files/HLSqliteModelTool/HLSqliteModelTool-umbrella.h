#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HLModelProtocol.h"
#import "HLModelTool.h"
#import "HLSqliteModelTool.h"
#import "HLSqliteTool.h"
#import "HLTableTool.h"

FOUNDATION_EXPORT double HLSqliteModelToolVersionNumber;
FOUNDATION_EXPORT const unsigned char HLSqliteModelToolVersionString[];

