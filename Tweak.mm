#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

#ifndef RTLD_NOW
#define RTLD_NOW 0x2
#endif

// خديعة الرد: إيه بيانات ترجع، هنغيرها لبيانات "نجاح" وصلاحية أسبوع
@interface NSURLSession (DoonFake)
@end

@implementation NSURLSession (DoonFake)
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    // تعريف الرد المزور اللي فيه صلاحية أسبوع (Expire in 7 days)
    NSString *fakeResponse = @"{\"status\":\"success\", \"message\":\"Licensed\", \"expiry\":\"2026-01-14\", \"days_left\":7}";
    NSData *fakeData = [fakeResponse dataUsingEncoding:NSUTF8StringEncoding];
    
    // صنع رد وهمي (200 OK) لحل مشكلة السيرفر
    NSHTTPURLResponse *fakeURLResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"Content-Type": @"application/json"}];

    // تنفيذ الـ Task بالبيانات المزورة بدل الأصلية
    return [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(fakeData, (NSURLResponse *)fakeURLResponse, nil);
        }
    }];
}
@end

__attribute__((constructor)) static void doonStrikeFinal() {
    // تحميل المكتبات مع حل مشكلة الـ identifier اللي في صوره 1188
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    
    NSLog(@"[DooN] License Spoofing: 7 Days Active ✅");
}