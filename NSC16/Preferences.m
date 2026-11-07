#import <Preferences/Preferences.h>

@interface NSC16SettingsController : PSListController
@end

@implementation NSC16SettingsController
- (id)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"NSC16";
}
@end