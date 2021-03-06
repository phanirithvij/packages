// Autogenerated from Pigeon (v0.1.20), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class Value;

@interface Value : NSObject
@property(nonatomic, strong, nullable) NSNumber *number;
@end

@interface Api2Flutter : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)calculate:(Value *)input completion:(void (^)(Value *, NSError *_Nullable))completion;
@end
@protocol Api2Host
- (void)calculate:(nullable Value *)input
       completion:(void (^)(Value *_Nullable, FlutterError *_Nullable))completion;
@end

extern void Api2HostSetup(id<FlutterBinaryMessenger> binaryMessenger, id<Api2Host> _Nullable api);

NS_ASSUME_NONNULL_END
