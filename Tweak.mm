#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة تصنيع ملف تفعيل وهمي (بيانات 2036)
void createFakeDoonLicense() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // بنلف على الملفات اللي جوه الفولدر
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:docsPath error:nil];
    for (NSString *item in contents) {
        NSString *fullPath = [docsPath stringByAppendingPathComponent:item];
        
        // لو لقينا ملف الكود أو الترخيص
        if ([item.lowercaseString containsString:@"key"] || [item.lowercaseString containsString:@"lic"]) {
            NSError *error;
            NSString *data = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
            
            if (data) {
                // تعديل التاريخ داخل الملف لـ 2036
                NSString *newData = [data stringByReplacingOccurrencesOfString:@"2026" withString:@"2036"];
                [newData writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
    }
}

// دالة تعديل الاسم في القائمة
void patchDoonBranding() {
    Method original = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (original) {
        IMP originalImp = method_getImplementation(original);
        method_setImplementation(original, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            if (text) {
                if ([text.lowercaseString containsString:@"pixel"] || [text.lowercaseString containsString:@"raid"]) {
                    text = @"DOON RAID IOS ✅";
                }
                if ([text containsString:@"2026"]) {
                    text = [text stringByReplacingOccurrencesOfString:@"2026" withString:@"2036"];
                }
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));
    }
}

__attribute__((constructor)) static void doonUltimateEntry() {
    // تحميل مكتبة الكراك
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // فحص وتعديل الملفات كل 3 ثواني لضمان كسر الحماية
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 20; i++) {
            [NSThread sleepForTimeInterval:3.0];
            dispatch_async(dispatch_get_main_queue(), ^{
                createFakeDoonLicense();
                patchDoonBranding();
            });
        }
    });
}