// CJAffiliate.h
//
// SDK Version:      2.0.0_136_7d3f648
// More Information: http://developer.cj.com

#import <Foundation/Foundation.h>
@class CJAFSaleInfo;
@class CJAFItem;

/**
 `CJAF` provides methods to notify CJ of application events, including installation, startup and 
 in-app events such as sales.
 
 Note that application code must initialize the SDK by invoking `appStarted` before reporting any in-app events.
 */
@interface CJAF : NSObject

/**
 * @name Initializing the SDK
 */

/**
 Initializes the SDK.
 
 This operation must be invoked from `didFinishLaunchingWithOptions`, before any tracking operations are invoked.
 When the app is started for the first time, will report the app install to CJ.
 */
+ (void) appStarted;


/**
 * @name Reporting In-App Events
 */

/**
 Report an in-app event to CJ.
 
 Use this operation to report an in-app event to CJ. This operation will have no effect if it is not preceded by a 
 successful call to `appStarted`.
 
 @param eventName Short (< 20 character), free-form description of the type of event, e.g. "signup", "login", 
 "in-game-sale".
 @param orderId Free-form, unique identifier for this sale/lead/event. The orderId is a unique identifier such as an 
 Invoice # or Order ID. This value truncates after the 96th character, and is used to cross-reference with CJ’s 
 system to validate each event.
 
 @warning Please note that CJ prohibits the submission of personally identifiable information — such as a full or 
 partial email address—in the orderId parameter.
 */

+ (void) reportInAppEvent:(NSString *) eventName
              withOrderId:(NSString *) orderId;

/**
 Report an in-app event containing sale details to CJ.
 
 Use this operation to report an in-app event to CJ. This operation will have no effect if it is not preceded by a
 successful call to `appStarted`.
 
 @param eventName Short (< 20 character), free-form description of the type of event, e.g. "signup", "login",
 "in-game-sale".
 @param orderId Free-form, unique identifier for this sale/lead/event. The orderId is a unique identifier such as an
 Invoice # or Order ID. This value truncates after the 96th character, and is used to cross-reference with CJ’s
 system to validate each event.
 @param saleInfo A CJAFSaleInfo object containing additional details about a sale.
 
 @warning Please note that CJ prohibits the submission of personally identifiable information — such as a full or
 partial email address—in the orderId parameter.
 */
+ (void) reportInAppEvent:(NSString *) eventName
              withOrderId:(NSString *) orderId
             withSaleInfo:(CJAFSaleInfo *) saleInfo;

@end

/**
 `CJAFSaleInfo` encapsulates detailed information about a sale event.
 
 To communicate summary information such as
 amount, currency and discounts, use one of the non-itemized, or "simpleSale" class methods. To specify item level 
 information use the "itemizedSale" class methods in conjunction with  the `CJAFItem` and `CJAFItemDetails` objects.
 
 ### Itemized Sales
 
 #### Items
 Items are instances of the `CJAFItem` class. A maximum of 100 items is allowed.
 
 #### Currency
 Identifies the currency used to determine the amount for each item involved in the sale. For a list of supported
 currencies and codes, please visit the Support Center.
 
 The system assumes the amount of the items is in the currency specified. If you specify a currency other than your 
 functional currency, the system converts the amount to an amount in your functional currency using a current 
 conversion rate.
 
 #### Amount Discounted
 Amount Discounted enables you to apply a whole order discount to a sale. A sale which contain multiple items 
 distributes the discount throughout the items, based on the item amounts.
 
 ### Simple Sale
 
 #### Total Amount
 Indicates the value of the sale in either the currency specified or your functional currency.
 
 The system assumes the total amount is in the currency specified. If you specify a currency other than your
 functional currency, the system converts the amount to an amount in your functional currency using a current
 conversion rate.
 
 #### Currency
 Identifies the currency used to determine the amount for each item involved in the sale. For a list of supported
 currencies and codes, please visit the Support Center.
 
 #### Amount Discounted
 Amount Discounted enables you to apply a whole order discount to a sale.
 */
@interface CJAFSaleInfo : NSObject

@property (readonly) NSDecimalNumber * amountDiscounted;
@property (readonly) NSString * currency;

/**
 * @name Creating a CJAFSaleInfo for an itemized sale
 */

/**
 Creates a `CJAFSaleInfo` for an itemized sale, with currency set to the advertiser's functional currency and no
 discount specified.
 
 @param items An `NSArray` of `CJAFItem` instances, representing the items of the sale.
 */
+ (CJAFSaleInfo *) itemizedSale:(NSArray *) items;

/**
 Creates a `CJAFSaleInfo` for an itemized sale, with the specified currency and no discount specified.
 
 @param items An `NSArray` of CJAFItem instances, representing the items of the sale.
 @param currency Identifies the currency used to determine the amount value for each item involved in the sale.
 */
+ (CJAFSaleInfo *) itemizedSale:(NSArray *) items
                   withCurrency:(NSString *) currency;

/**
 Creates a `CJAFSaleInfo` for an itemized sale, with currency set to the advertiser's functional currency and the
 specified discount amount.

 @param items An `NSArray` of CJAFItem instances, representing the items of the sale.
 @param amountDiscounted Total monetary value discounted from the entire sale.
*/
+ (CJAFSaleInfo *) itemizedSale:(NSArray *) items
           withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

/**
 Creates a `CJAFSaleInfo` for an itemized sale, with the specified currency and the specified discount amount.

 @param items An `NSArray` of CJAFItem instances, representing the items of the sale.
 @param currency Identifies the currency used to determine the amount value for each item involved in the sale.
 @param amountDiscounted Total monetary value discounted from the entire sale.
*/
+ (CJAFSaleInfo *) itemizedSale:(NSArray *) items
                   withCurrency:(NSString *) currency
           withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

/**
 * @name Creating a CJAFSaleInfo for a non-itemized sale.
 */

/**
 Creates a `CJAFSaleInfo` for a non-itemized sale, with the specified total amount, the currency set to the advertiser's
 functional currency and no discount amount.
 
 @param totalAmount Total monetary value of the sale, not including shipping or tax.
 */
+ (CJAFSaleInfo *) simpleSale:(NSDecimalNumber *) totalAmount;

/**
 Creates a `CJAFSaleInfo` for a non-itemized sale, with the specified total amount, specified currency and no
 discount amount.
 
 @param totalAmount Total monetary value of the sale, not including shipping or tax.
 @param currency Identifies the currency used to determine the amount value for each item involved in the sale.
 */
+ (CJAFSaleInfo *) simpleSale:(NSDecimalNumber *) totalAmount
                 withCurrency:(NSString *) currency;

/**
 Creates a `CJAFSaleInfo` for a non-itemized sale, with the specified total amount, the currency set to the advertiser's 
 functional currency and the specified discount amount.
 
 @param totalAmount Total monetary value of the sale, not including shipping or tax.
 @param amountDiscounted Total monetary value discounted from the entire sale.
 */
+ (CJAFSaleInfo *) simpleSale:(NSDecimalNumber *) totalAmount
         withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

/**
 Creates a `CJAFSaleInfo` for a non-itemized sale, with the specified total amount, specified currency and the
 specified discount amount.
 
 @param totalAmount Total monetary value of the sale, not including shipping or tax.
 @param currency Identifies the currency used to determine the amount value for each item involved in the sale.
 @param amountDiscounted Total monetary value discounted from the entire sale.
 */
+ (CJAFSaleInfo *) simpleSale:(NSDecimalNumber *) totalAmount
                 withCurrency:(NSString *) currency
         withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

- (NSDictionary * ) toParameterDictionary;
@end



@interface CJAFBasicSaleInfo: CJAFSaleInfo

@property (readonly) NSDecimalNumber * totalAmount;

- (id) initWithTotalAmount:(NSDecimalNumber *) _totalAmount
      withAmountDiscounted:(NSDecimalNumber *) _amountDiscounted
              withCurrency: (NSString *) _currency;

@end


@interface CJAFItemizedSaleInfo : CJAFSaleInfo

@property (readonly) NSArray * items;

- (id) initWithItems:(NSArray *) items
withAmountDiscounted:(NSDecimalNumber *) amountDiscounted
        withCurrency: (NSString *) currency;

@end

/**
 `CJAFItemDetails` encapsulates optional details about a sale item.
 */
@interface CJAFItemDetails : NSObject

/**
 Creates a `CJAFItemDetails`, specifying the item amount.
 
 @param amount Monetary value of a single quantity of a given item.
 */
+ (CJAFItemDetails *) itemDetailsWithAmount:(NSDecimalNumber *) amount;

/**
 Creates a `CJAFItemDetails`, specifying the item amount and quantity.
 
 @param amount Monetary value of a single quantity of a given item.
 @param quantity The number of items in the sale. The quantity value is multiplied by the amount value to determine the
 total for a given item.
 */
+ (CJAFItemDetails *) itemDetailsWithAmount:(NSDecimalNumber *) amount
                               withQuantity:(unsigned int) quantity;

/**
 Creates a `CJAFItemDetails`, specifying the item amount, quantity and discount amount.
 
 @param amount Monetary value of a single quantity of a given item.
 @param quantity The number of items in the sale. The quantity value is multiplied by the amount value to determine the
 total for a given item.
 @param amountDiscounted Monetary value discounted from a given item.
 */
+ (CJAFItemDetails *) itemDetailsWithAmount:(NSDecimalNumber *) amount
                       withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

/**
 Creates a `CJAFItemDetails`, specifying the item amount, quantity and discount amount.
 
 @param amount Monetary value of a single quantity of a given item.
 @param quantity The number of items in the sale. The quantity value is multiplied by the amount value to determine the 
 total for a given item.
 @param amountDiscounted Monetary value discounted from a given item.
 */
+ (CJAFItemDetails *) itemDetailsWithAmount:(NSDecimalNumber *) amount
                               withQuantity:(unsigned int) quantity
                       withAmountDiscounted:(NSDecimalNumber *) amountDiscounted;

- (NSDecimalNumber *) amount;
- (NSNumber *) quantity;
- (NSDecimalNumber *) amountDiscounted;

@end

/**
 `CJAFItem` encapsulates the information required to report conversion events to CJ.
 */
@interface CJAFItem : NSObject

/**
 Creates a `CJAFItem` with the specified sku.
 
 @param sku String value identifying an item. The CJ system supports an alphanumeric string with dashes or underscores
 for the sku value. Spaces and other characters such as commas or slashes are not permitted in the sku. Sku values must
 be less than or equal to 100 characters.
 */
+ (CJAFItem *) itemWithSKU:(NSString *) sku;

/**
 Creates a `CJAFItem` with the specified sku and `CJAFItemDetails` object.
 
 @param sku String value identifying an item. The CJ system supports an alphanumeric string with dashes or underscores 
 for the sku value. Spaces and other characters such as commas or slashes are not permitted in the sku. Sku values must 
 be less than or equal to 100 characters.
 @param details A `CJAFItemDetails` object containing additional information about a given item.
 */
+ (CJAFItem *) itemWithSKU:(NSString *) sku withDetails:(CJAFItemDetails *) details;

- (NSString *) sku;
- (CJAFItemDetails *) details;
- (BOOL) hasDetails;

@end

@protocol CJAFLog
- (void) debug:(NSString *) message;
- (void) info:(NSString *) message;
@end

@interface CJAFConfig : NSObject
+ (NSString *) mobileTrackingServerBaseUrl;
+ (NSObject<CJAFLog> *) logger;
+ (void) setMobileTrackingServerBaseUrl:(NSString *) url;
+ (void) setLogger:(NSObject<CJAFLog> *) logger;
@end
