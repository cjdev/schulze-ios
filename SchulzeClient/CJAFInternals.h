#import <Foundation/Foundation.h>
#import "CJAffiliate.h"

@interface CJInternals : NSObject

+ (NSString*)dictToQueryString: (NSDictionary*)dict;

+ (NSDictionary *) identify;

+ (BOOL)appStarted: (NSString*)trackingServerBaseUrl
   withDebugLogger: (id <CJAFLog>)logger;

+ (BOOL)appStarted: (NSString*)trackingServerBaseUrl
        withDebugLogger: (id <CJAFLog>)logger
   withBrowserOpenFunction: (void (^)(NSString*))browserOpenFunction
withDeviceIdentityFunction: (NSDictionary* (^)())deviceIdentityFunction;

+ (BOOL)appStarted: (NSString*)trackingServerBaseUrl
        withDebugLogger: (id <CJAFLog>)logger
   withBrowserOpenFunction: (void (^)(NSString*))browserOpenFunction
withDeviceIdentityFunction: (NSDictionary* (^)())deviceIdentityFunction
       withHttpGetFunction: (NSData* (^)(NSURLRequest*, NSURLResponse**, NSError**))httpGetFunction;


+ (BOOL)reportInAppEvent: (NSString*)eventName
             withOrderId: (NSString*)orderId
             withSaleInfo: (CJAFSaleInfo*)saleInfo
withTrackingServerBaseUrl: (NSString*)trackingServerBaseUrl
          withDebugLogger: logger;

+ (BOOL)reportInAppEvent: (NSString*)eventName
             withOrderId: (NSString*)orderId
             withSaleInfo: (CJAFSaleInfo*)saleInfo
withTrackingServerBaseUrl: (NSString*)trackingServerBaseUrl
           withDebugLogger: logger
withDeviceIdentityFunction: (NSDictionary* (^)())deviceIdentityFunction;

+ (BOOL)reportInAppEvent: (NSString*)eventName
             withOrderId: (NSString*)orderId
             withSaleInfo: (CJAFSaleInfo*)saleInfo
withTrackingServerBaseUrl: (NSString*)trackingServerBaseUrl
           withDebugLogger: logger
withDeviceIdentityFunction: (NSDictionary* (^)())deviceIdentityFunction
       withHttpGetFunction: (NSData* (^)(NSURLRequest*, NSURLResponse**, NSError**))httpGetFunction;

+ (BOOL) trackEvent:(NSString * ) trackingServerBaseUrl
    withDebugLogger:(id <CJAFLog>) logger
withBrowserOpenFunction:(void (^)(NSString*)) browserOpenFunction
 withDeviceIdentity:(NSDictionary *) attributionData
withHttpGetFunction:(NSData * (^)(NSURLRequest*, NSURLResponse **, NSError **)) httpGetFunction;

+ (void)  handleException:(NSException *)exception
withTrackingServerBaseUrl:(NSString *)trackingServerBaseUrl
         withHttpFunction:(NSData *(^)(NSURLRequest *, NSURLResponse **, NSError **))httpFunction
         withTimeFunction:(NSTimeInterval (^)())timeFunction
       withDeviceInfoDict:(NSDictionary *)attributionData
          withDebugLogger: (id <CJAFLog>) logger;

@end
