#import "HBRootListController.h"
#import <spawn.h>
#import <sys/wait.h>

extern char **environ;

static BOOL SpawnRespring(const char *path, char *const argv[]) {
    pid_t pid = 0;
    if (posix_spawn(&pid, path, NULL, NULL, argv, environ) != 0)
        return NO;
    waitpid(pid, NULL, 0);
    return YES;
}

@implementation HBRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"HomeBarSizer" target:self];
    }
    return _specifiers;
}

- (void)respring {
    char *sbreloadArgv[] = {"sbreload", NULL};
    const char *sbreloadPaths[] = {
        "/var/jb/usr/bin/sbreload",
        "/usr/bin/sbreload",
        NULL,
    };
    for (const char **path = sbreloadPaths; *path; path++) {
        if (SpawnRespring(*path, sbreloadArgv))
            return;
    }

    char *killallArgv[] = {"killall", "SpringBoard", NULL};
    const char *killallPaths[] = {
        "/var/jb/usr/bin/killall",
        "/usr/bin/killall",
        NULL,
    };
    for (const char **path = killallPaths; *path; path++) {
        if (SpawnRespring(*path, killallArgv))
            return;
    }
}

@end
