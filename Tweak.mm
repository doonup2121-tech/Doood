#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دالة تزوير الرد
@interface NSData (DoonMock)
@end

@implementation NSData (DoonMock)
// هنخلي أي بيانات جاية من السيرفر كأنها بتقول "Success"
+ (instancetype)doon_dataWithContentsOfURL:(NSURL *)url {
    NSLog(@"[DooN] Intercepted URL: %@", url.absoluteString);
    // لو الرابط يخص سيرفر الكراك، نبعت رد وهمي
    if ([url.absoluteString containsString:@"crack"]) {
        NSString *fakeResponse = @"{\"status\":\"success\", \"key\":\"valid\", \"expire\":\"2099\"}";
        return [fakeResponse dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [self doon_dataWithContentsOfURL:url]; // لو رابط عادي خليه يكمل
}
@end

__attribute__((constructor)) static void doonServerMock() {
    // 1. تشغيل "الخديعة" فوراً
    Class class = [NSData class];
    Method original = class_getClassMethod(class, @selector(dataWithContentsOfURL:));
    Method swizzled = class_getClassMethod(class, @selector(doon_dataWithContentsOfURL:));
    method_exchangeImplementations(original, swizzled);

    // 2. تحميل المكتبات
    // ده بيضمن إن لما المكتبة تفتح وتطلب السيرفر، تلاقي الرد الوهمي بتاعنا جاهز
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    
    NSLog(@"[DooN] Server Mocking Active ✅");
}