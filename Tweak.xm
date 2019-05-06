#import "Header.h"
#import <UIKit/UIAlertController+Private.h>
#import <UIKit/UIColor+Private.h>
#import <substrate.h>

void viewDidLoadHook(id self) {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressPackage:)];
    gesture.minimumPressDuration = 0.35;
    gesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    gesture.delaysTouchesBegan = YES;
    [[self collectionView] addGestureRecognizer:gesture];
    [gesture release];
    [NSClassFromString(@"RepoManaager") sharedInstance];
    [NSClassFromString(@"PackageListManager") sharedInstance];
}

BOOL shouldReceiveTouchHook(BOOL orig, UIGestureRecognizer *gesture) {
    if (!orig && [gesture isKindOfClass:[UILongPressGestureRecognizer class]])
        return YES;
    return orig;
}

Package *findPackageInRepo(Package *fpackage) {
    NSString *fpackageString = [fpackage.package lowercaseString];
    for (Repo *repo in [[NSClassFromString(@"RepoManager") sharedInstance] repoList]) {
        for (Package *package in repo.packages) {
            if ([fpackageString isEqualToString:[package.package lowercaseString]]) {
                return package;
            }
        }
    }
    return nil;
}

void didLongPressGesture(UILongPressGestureRecognizer *gesture, UIViewController <SileoPackageListViewControllerDelegate> *self) {
    if (gesture.state == UIGestureRecognizerStateChanged)
        return;
    UICollectionView *collectionView = [self collectionView];
    CGPoint p = [gesture locationInView:collectionView];
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:p];
    if (indexPath) {
        PackageCollectionViewCell *cell = (PackageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.highlighted = NO;
        if (gesture.state == UIGestureRecognizerStateBegan) {
            cell.highlighted = YES;
            return;
        }
        UIView *oldButton = [cell viewWithTag:2222];
        [oldButton removeFromSuperview];
        [oldButton release];
        if (gesture.state != UIGestureRecognizerStateEnded)
            return;
        Package *package = findPackageInRepo(cell.targetPackage);
        PackageQueueButton *button = [NSClassFromString(@"PackageQueueButton") new];
        button.package = cell.targetPackage;
        button.shouldCheckPurchaseStatus = NO;
        if (package) {
            [cell.targetPackage release];
            cell.targetPackage = package;
            button.package = package;
        }
        button.frame = CGRectMake(cell.frame.size.width / 2, cell.frame.size.height / 2, 1, 1);
        button.tag = 2222;
        [cell addSubview:button];
        button.hidden = YES;
        UIAlertController *actions = [UIAlertController alertControllerWithTitle:button.package.name message:[NSString stringWithFormat:@"Version: %@\nAuthor(s): %@", button.package.version, button.package.author] preferredStyle:UIAlertControllerStyleActionSheet];
        if (IS_IPAD)
            actions.popoverPresentationController.sourceView = button;
        button.viewControllerForPresentation = self;
        BOOL commercial = button.package.commercial;
        button.package.commercial = NO;
        // BOOL installed = [[NSClassFromString(@"PackageListManager") sharedInstance] installedPackageWithIdentifier:button.package.package] != nil;
        for (UIPreviewAction *previewAction in button.previewActionItems) {
            [actions _addActionWithTitle:previewAction.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (previewAction.handler)
                    previewAction.handler(previewAction, actions);
            }];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"Cancel" value:@"" table:nil] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [actions dismissViewControllerAnimated:YES completion:NULL];
        }];
        [actions addAction:cancel];
        button.package.commercial = commercial;
        [button.viewControllerForPresentation presentViewController:actions animated:YES completion:NULL];   
    }
}

%hook PackageListViewController

- (void)viewDidLoad {
    %orig;
    viewDidLoadHook(self);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(id)arg2 {
    return shouldReceiveTouchHook(%orig, gesture);
}

%new
- (void)didLongPressPackage:(UILongPressGestureRecognizer *)gesture {
    didLongPressGesture(gesture, self);
}

%end

%hook NewsViewController

- (void)viewDidLoad {
    %orig;
    viewDidLoadHook(self);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(id)arg2 {
    return shouldReceiveTouchHook(%orig, gesture);
}

%new
- (void)didLongPressPackage:(UILongPressGestureRecognizer *)gesture {
    didLongPressGesture(gesture, self);
}

%end

%hook InstallViewController

%property(assign) int trueReturnButtonAction;

NSString *keys[] = {
    @"Done", nil, @"After_Install_Relaunch", nil, @"After_Install_Respring", @"After_Install_Reboot"
};

- (void)viewDidLoad {
    %orig;
    UIButton *completeButton = [self valueForKey:@"_completeButton"];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(completeButtonLongPressed:)];
    [completeButton addGestureRecognizer:gesture];
    [gesture release];
}

%new
- (void)completeButtonLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        MSHookIvar<int>(self, "_returnButtonAction") = self.trueReturnButtonAction;
        [self completeButtonTapped:nil];
    }
}

- (void)updateCompleteButton {
    int trueReturnButtonAction = MSHookIvar<int>(self, "_returnButtonAction");
    self.trueReturnButtonAction = trueReturnButtonAction;
    NSString *trueAction = nil;
    if (trueReturnButtonAction > 1) {
        NSString *key = keys[trueReturnButtonAction] ?: keys[trueReturnButtonAction + 1];
        trueAction = [NSBundle.mainBundle localizedStringForKey:key value:@"" table:nil];
        MSHookIvar<int>(self, "_returnButtonAction") = 0;
    }
    %orig;
    if (trueAction) {
        UIButton *completeButton = [self valueForKey:@"_completeButton"];
        [completeButton setTitle:[NSString stringWithFormat:@"%@ (%@)", [NSBundle.mainBundle localizedStringForKey:keys[0] value:@"" table:nil], trueAction] forState:0];
    }
}

%end

%ctor {
    %init;
}