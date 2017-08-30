//
//  WALErrorDomain.h
//  WalleeSDK
//
//  Created by Daniel Schmid on 14.08.17.
//  Copyright © 2017 smoca AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const WALErrorDomain;

/**


 - WALErrorInvalidCredentials: WALErrorInvalidCredentials description
 - WALErrorInvalidState: WALErrorInvalidState description
 - WALErrorInvalidArgument: WALErrorInvalidArgument description
 - WALErrorHTTPError: WALErrorHTTPError description
 */
typedef NS_ENUM(NSUInteger, WALError){
    WALErrorInvalidCredentials  = 100,
    WALErrorInvalidState        = 200,
    WALErrorInvalidArgument     = 300,
    WALErrorHTTPError     = 900,
};

@interface WALErrorHelper : NSObject
+ (void)populate:(NSError **)error withInvalidCredentialsWithMessage:(NSString *)message;
+ (void)populate:(NSError **)error withIllegalStateWithMessage:(NSString *)message;
+ (void)populate:(NSError **)error withIllegalArgumentWithMessage:(NSString *)message;

+ (BOOL)checkArrayType:(id)object withMessage:(NSString * _Nullable)message error:(NSError * _Nullable *)error;
+ (BOOL)checkDictionaryType:(id)object withMessage:(NSString *)message error:(NSError * _Nullable __autoreleasing *)error;
@end

NS_ASSUME_NONNULL_END