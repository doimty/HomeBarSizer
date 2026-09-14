#import "HBRootListController.h"
#import <spawn.h>
#include <roothide.h>

extern char **environ;

static void SpawnJBRoot(NSString *relativePath, char *const argv[]) {
    NSString *resolved = jbroot(relativePath);
    const char *path = resolved.length ? resolved.fileSystemRepresentation : relativePath.fileSystemRepresentation;
    pid_t pid = 0;
    posix_spawn(&pid, path, NULL, NULL, argv, environ);
}

@implementation HBRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"HomeBarSizer" target:self];
    }
    return _specifiers;
}

- (void)respring {
    // Same path Cephei / Vedette use from a PreferenceBundle: ask FrontBoard
    // to restart SpringBoard. No hardcoded jailbreak prefix, no Darwin broadcast.
    [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoardServices.framework"] load];
    [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardServices.framework"] load];

    Class relaunchAction = NSClassFromString(@"SBSRelaunchAction");
    Class systemService = NSClassFromString(@"FBSSystemService");
    if ([relaunchAction respondsToSelector:@selector(actionWithReason:options:targetURL:)] &&
        [systemService respondsToSelector:@selector(sharedService)]) {
        id action = [relaunchAction actionWithReason:@"RestartRenderServer"
                                            options:4
                                          targetURL:[NSURL URLWithString:@"prefs:root=HomeBarSizer"]];
        id service = [systemService sharedService];
        if (action && service && [service respondsToSelector:@selector(sendActions:withResult:)]) {
            [service sendActions:[NSSet setWithObject:action] withResult:nil];
            return;
        }
    }

    char *sbreloadArgv[] = {"sbreload", NULL};
    SpawnJBRoot(@"/usr/bin/sbreload", sbreloadArgv);
    char *killallArgv[] = {"killall", "SpringBoard", NULL};
    SpawnJBRoot(@"/usr/bin/killall", killallArgv);
}

@end
