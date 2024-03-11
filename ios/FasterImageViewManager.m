#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(FasterImageViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)

RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onSuccess, RCTDirectEventBlock)

@end
