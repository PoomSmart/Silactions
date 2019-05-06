#import "../PS.h"

@interface Package : NSObject
@property(assign) BOOL commercial;
@property(assign) BOOL essential;
@property(assign) int status;
@property(retain, nonatomic) NSString *author;
@property(retain, nonatomic) NSString *name;
@property(retain, nonatomic) NSString *package;
@property(retain, nonatomic) NSString *packageID;
@property(retain, nonatomic) NSString *section;
@property(retain, nonatomic) NSString *version;
@property(retain, nonatomic) NSString *sourceFile;
@property(retain, nonatomic) NSMutableArray <Package *> *allVersions;
@end

@interface Repo : NSObject
- (NSArray <Package *> *)packages;
@property(retain, nonatomic) NSString *rawEntry;
@end

@interface RepoManager : NSObject
+ (instancetype)sharedInstance;
- (NSMutableArray <Repo *> *)repoList;
@end

@interface PackageListManager : NSObject
+ (instancetype)sharedInstance;
- (void)loadAllPackages;
- (Package *)installedPackageWithIdentifier:(NSString *)identifier;
@end

@interface WishListManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isPackageInWishList:(NSString *)package;
@end

@interface PackageViewController : UIViewController
@property(retain, nonatomic) Package *package;
- (void)updatePurchaseStatus;
@end

@interface PackageViewController (Additions)
@property(assign) BOOL fromHold;
@end

@protocol SileoPackageListViewControllerDelegate <UICollectionViewDelegate>
- (UICollectionView *)collectionView;
- (PackageViewController *)controllerForIndexPath:(NSIndexPath *)indexPath;
@end

@interface PackageListViewController : UIViewController <UIGestureRecognizerDelegate, SileoPackageListViewControllerDelegate>
@end

@interface NewsViewController : UIViewController <UIGestureRecognizerDelegate, SileoPackageListViewControllerDelegate>
@end

@interface PackageCollectionViewCell : UICollectionViewCell
@property(retain, nonatomic) Package *targetPackage;
@property(retain, nonatomic) UILabel *authorLabel;
@property(retain, nonatomic) UILabel *titleLabel;
@property(retain, nonatomic) UILabel *descriptionLabel;
@end

@interface PackageQueueButton : UIButton
@property(retain, nonatomic) Package *package;
@property(retain, nonatomic) PackageViewController *dataProvider;
@property(retain, nonatomic) NSString *overrideTitle;
@property(retain, nonatomic) UIViewController *viewControllerForPresentation;
@property(assign) BOOL shouldCheckPurchaseStatus; 
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems;
- (void)buttonTapped:(id)arg1;
- (void)showDowngradePrompt:(id)arg1;
- (void)updatePurchaseStatus;
- (void)setup;
@end

@interface InstallViewController : UIViewController
@property(assign) int trueReturnButtonAction;
- (void)completeButtonTapped:(id)arg1;
@end