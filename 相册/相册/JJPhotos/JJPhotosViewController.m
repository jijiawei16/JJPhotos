//
//  JJPhotosViewController.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosViewController.h"
#import "JJPhotoManager.h"
#import "JJPhotosCollection.h"
#import "JJPhotosCollectionFlowLayout.h"
#import "JJPhotosScroll.h"
#import "JJAlbumListTableView.h"
#import "UIButton+JJType.h"///按钮图片文字样式设置

//#define header_h 64
//#define footer_h 50
#define sw self.view.frame.size.width
#define sh self.view.frame.size.height
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
@interface JJPhotosViewController ()<JJPhotosCollectionDelegate,JJAlbumListTableViewDelegate,JJPhotosScrollDelegate>

@property (nonatomic , strong) UIView *header;
@property (nonatomic , strong) UIView *footer;
@property (nonatomic , strong) JJPhotosCollection *collection;
@property (nonatomic , strong) NSArray *items;
@property (nonatomic , strong) NSArray *assets;
@property (nonatomic , strong) PHAssetCollection *assetCollection;
@property (nonatomic , copy) JJPhotosViewControllerCallBack block;
@end

@implementation JJPhotosViewController
{
    UIButton *confirm;
    CGFloat header_h;
    CGFloat footer_h;
    UIButton *albumListBackGround;///相册列表背景
    JJAlbumListTableView *albumList;///相册列表
    UIButton *albumListBtn;///相册列表按钮
    NSString *photoListName;///用来判断相册列表的标识
    UIButton *artwork;///原图选择按钮
    UILabel *artLab;///原图大小lab
    BOOL needSelect;///是否需要自动选中第一个照片
}
- (instancetype)initWithcallBack:(JJPhotosViewControllerCallBack)callBack
{
    self = [super init];
    if (self) {
        self.block = callBack;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightTextColor];
    self.assetCollection = nil;
    photoListName = @"相机胶卷";
    needSelect = NO;
    if (iPhoneX) {
        header_h = 88;
        footer_h = 83;
    }else {
        header_h = 64;
        footer_h = 49;
    }
    // 添加视图
    [self.view addSubview:self.header];
    [self.view addSubview:self.footer];
    [self.view addSubview:self.collection];
    
    // 添加子视图
    [self creatSubViews];
    
    // 判断相册权限问题
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){//用户之前已经授权
        
        [self reloadItems];
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied){//用户之前已经拒绝授权
        
        NSLog(@"用户之前已经拒绝授权");
        
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){//用户还没有授权
        NSLog(@"用户还没有授权");
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {// 监听相册授权点击事件
                
                NSLog(@"用户允许访问相册了");
                dispatch_async(dispatch_get_main_queue(), ^{//主线埕执行
        
                    [self reloadItems];
                });
                return;
            }
            NSLog(@"用户拒绝访问相册");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}
- (void)creatSubViews
{
    // 原图按钮
    artwork = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 70, 30)];
    artwork.selected = NO;
    [artwork setTitle:@"原图" forState:UIControlStateNormal];
    [artwork setImage:[UIImage imageNamed:@"artworkNomal"] forState:UIControlStateNormal];
    [artwork setImage:[UIImage imageNamed:@"artworkSelect"] forState:UIControlStateSelected];
    [artwork layoutButtonWithEdgeInsetsStyle:JJButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [artwork setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [artwork addTarget:self action:@selector(artwork:) forControlEvents:UIControlEventTouchUpInside];
    artwork.titleLabel.font = [UIFont systemFontOfSize:16];
    [_footer addSubview:artwork];
    
    // 原图大小
    artLab = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 70, 30)];
    artLab.text = @"(0.0M)";
    artLab.font = [UIFont systemFontOfSize:14];
    artLab.textColor = [UIColor whiteColor];
    artLab.textAlignment = NSTextAlignmentLeft;
    artLab.hidden = YES;
    [_footer addSubview:artLab];
    
    // 确定按钮
    confirm = [[UIButton alloc] initWithFrame:CGRectMake(sw-75, 10, 60, 30)];
    [confirm setTitle:@"完成" forState:UIControlStateNormal];
    confirm.userInteractionEnabled = NO;
    [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [confirm setBackgroundColor:[UIColor lightGrayColor]];
    confirm.layer.cornerRadius = 5.0;
    confirm.layer.masksToBounds = YES;
    confirm.titleLabel.font = [UIFont systemFontOfSize:14];
    [_footer addSubview:confirm];
    
    // 取消按钮
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(15, header_h-40, 50, 30)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [_header addSubview:cancel];
    
    // 相册列表按钮
    albumListBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw/2-50, header_h-40, 100, 30)];
    [albumListBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [albumListBtn setImage:[UIImage imageNamed:@"下拉"] forState:UIControlStateNormal];
    [albumListBtn setImage:[UIImage imageNamed:@"收回"] forState:UIControlStateSelected];
    [albumListBtn layoutButtonWithEdgeInsetsStyle:JJButtonEdgeInsetsStyleRight imageTitleSpace:5];
    [albumListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [albumListBtn addTarget:self action:@selector(albumList:) forControlEvents:UIControlEventTouchUpInside];
    albumListBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_header addSubview:albumListBtn];
    
    // 预览按钮
    UIButton *preview = [[UIButton alloc] initWithFrame:CGRectMake(sw-65, header_h-40, 50, 30)];
    [preview setTitle:@"预览" forState:UIControlStateNormal];
    [preview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [preview addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    preview.titleLabel.font = [UIFont systemFontOfSize:16];
    [_header addSubview:preview];
}

#pragma mark 懒加载
- (UIView *)header
{
    if (_header == nil) {
        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, header_h)];
        _header.backgroundColor = [UIColor colorWithRed:41/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    }
    return _header;
}
- (UIView *)footer
{
    if (_footer == nil) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, sh-footer_h, sw, footer_h)];
        _footer.backgroundColor = [UIColor colorWithRed:41/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    }
    return _footer;
}
- (JJPhotosCollection *)collection
{
    if (_collection == nil) {
        JJPhotosCollectionFlowLayout *layout = [[JJPhotosCollectionFlowLayout alloc] init];
        _collection = [[JJPhotosCollection alloc] initWithFrame:CGRectMake(0, header_h, sw, sh-header_h-footer_h) collectionViewLayout:layout];
        _collection.jj_delegate = self;
    }
    return _collection;
}
#pragma mark 代理方法和按钮点击方法
- (void)JJPhotosCollectionDidSelectCell
{
    // 这里需要等一段时间才能操作,保存相册图片需要一段时间,用到了block回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        NSInteger num = [JJPhotoManager getSelectCells].count;
        if (num) {
            [confirm setBackgroundColor:[UIColor colorWithRed:235/255.0 green:37/255.0 blue:39/255.0 alpha:1]];
            confirm.userInteractionEnabled = YES;
            [confirm setTitle:[NSString stringWithFormat:@"完成(%ld)",(long)num] forState:UIControlStateNormal];
        }else {
            [confirm setBackgroundColor:[UIColor lightGrayColor]];
            [confirm setTitle:[NSString stringWithFormat:@"完成"] forState:UIControlStateNormal];
            confirm.userInteractionEnabled = NO;
        }
        artLab.text = [NSString stringWithFormat:@"(%.1f)M",[JJPhotoManager manager].selectSize/1024];
    });
}
- (void)JJPhotosCollectionReloadItems:(BOOL)reloadItems
{
    needSelect = reloadItems;
    if (!needSelect) return;
    [self reloadItems];
}

#pragma mark 刷新数据源
- (void)reloadItems
{
    // 设置数据源(collection:传某一个相册,如果传nil则获取相机胶卷 asending:是否按时间倒序排列)
    self.assets = [[JJPhotoManager manager] fetchAssetsInCollection:self.assetCollection asending:NO];
    self.items = self.assets;
    // 如果是相册的列表,展示拍照功能
    if ([photoListName isEqualToString:@"Camera Roll"]||[photoListName isEqualToString:@"相机胶卷"]) {
        NSMutableArray *temp = [NSMutableArray arrayWithObjects:@"拍照", nil];
        [temp addObjectsFromArray:_items];
        _items = temp;
    }
    [albumListBtn setTitle:photoListName forState:UIControlStateNormal];
    [albumListBtn layoutButtonWithEdgeInsetsStyle:JJButtonEdgeInsetsStyleRight imageTitleSpace:5];
    [JJPhotoManager reloadCellsAndArtworkSizesWithcount:self.items.count];
    [JJPhotoManager manager].maxCount = self.maxCount;
    self.collection.photoListName = photoListName;
    self.collection.needSelect = needSelect;
    self.collection.items = self.items;
}
#pragma  mark --------------------
- (void)artwork:(UIButton *)sender
{
    sender.selected = !sender.selected;
    artLab.hidden = !sender.selected;
}
- (void)preview:(UIButton *)sender
{
    NSArray *showCells = [JJPhotoManager getSelectCells];
    if (!showCells.count) {// 如果没有选择则不展示
        return;
    }
    [JJPhotosScroll showItmes:showCells index:0 delegate:self];
}
- (void)confirm:(UIButton *)sender
{
    // 这里判断是否发送原图
    if (artwork.selected) {
        self.block([JJPhotoManager getArtworks]);
    }else {
        self.block([JJPhotoManager getPhotos]);
    }
    [JJPhotoManager clear];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancel:(UIButton *)sender
{
    [JJPhotoManager clear];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 展示相册列表界面
- (void)albumList:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self showAlbumList];
    }else {
        [self albumListBackHidden];
    }
}
- (void)showAlbumList
{
    albumListBackGround = [[UIButton alloc] initWithFrame:CGRectMake(0, header_h, sw, sh-header_h)];
    albumListBackGround.backgroundColor = [UIColor blackColor];
    albumListBackGround.alpha = 0.5;
    [albumListBackGround addTarget:self action:@selector(albumListBackHidden) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumListBackGround];
    
    albumList = [[JJAlbumListTableView alloc] initWithFrame:CGRectMake(0, header_h, sw, sh-header_h-footer_h-100)];
    albumList.jj_delegate = self;
    [self.view addSubview:albumList];
    [albumList setUpItems:[[JJPhotoManager manager] getAllAblums]];
}
- (void)albumListBackHidden
{
    albumListBtn.selected = NO;
    [albumListBackGround removeFromSuperview];
    [albumList removeFromSuperview];
}
- (void)JJAlbumListTableViewDidSelectAlbum:(JJAblumInfo *)album
{
    [self albumListBackHidden];
    if ([photoListName isEqualToString:album.ablumName]) {
        return;
    }
    [JJPhotoManager clear];// 清除选择,重新选择
    self.assetCollection = album.assetCollection;
    photoListName = album.ablumName;
    needSelect = NO;
    [self reloadItems];
}
@end
