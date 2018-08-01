//
//  JJPhotosScroll.m
//  相册
//
//  Created by 16 on 2018/8/1.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosScroll.h"
#import "JJPhotosCollectionCell.h"
#import "JJPhotoManager.h"

#define sw self.frame.size.width
#define sh self.frame.size.height
#define IPHONEX ([UIScreen mainScreen].bounds.size.height == 812.0f)?YES:NO
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define nav_h (IPHONEX==YES)?88:64
#define bottom_h (IPHONEX==YES)?34:0

@interface JJPhotosScroll ()<UIScrollViewDelegate>

@property (nonatomic , assign) NSInteger index;
@property (nonatomic , strong) NSArray *items;
@property (nonatomic , strong) NSMutableArray *selects;
@property (nonatomic , strong) NSMutableArray *selectNums;
@property (nonatomic , assign) NSInteger currentNum;

@property (nonatomic , strong) UIView *header;
@property (nonatomic , strong) UIView *footer;
@property (nonatomic , strong) UIButton *back;
@property (nonatomic , strong) UIButton *select;
@property (nonatomic , strong) UILabel *title;
@property (nonatomic , strong) UIButton *sure;

@end
@implementation JJPhotosScroll

+ (void)showItmes:(NSArray *)items index:(NSInteger)index delegate:(id<JJPhotosScrollDelegate>)delegate
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:[[self alloc] initWithFrame:window.bounds items:items index:index delegate:delegate]];
}
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items index:(NSInteger)index delegate:(id<JJPhotosScrollDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, frame.size.height, frame.size.width+10, frame.size.height);
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0, 0, frame.size.width+10, frame.size.height);
        }];
        self.items = items;
        self.index = index;
        self.jj_delegate = delegate;
        self.pagingEnabled = YES;
        self.currentNum = 0;
        self.delegate = self;
        self.selects = [NSMutableArray array];
        self.selectNums = [NSMutableArray array];
        self.backgroundColor = [UIColor blackColor];
        [self creatImgs];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self creatSubViews];
        });
    }
    return self;
}
- (void)creatSubViews
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, nav_h)];
    _header.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [window addSubview:_header];
    
    _back = [[UIButton alloc] initWithFrame:CGRectMake(15, (nav_h)-35, 20, 20)];
    [_back setImage:[UIImage imageNamed:@"pop"] forState:UIControlStateNormal];
    [_back addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [_header addSubview:_back];
    
//    _select = [[UIButton alloc] initWithFrame:CGRectMake(sw-40, (nav_h)-35, 20, 20)];
//    [_select setTitle:[NSString stringWithFormat:@"%@",_selectNums[0]] forState:UIControlStateNormal];
//    [_select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _select.backgroundColor = [UIColor redColor];
//    _select.layer.cornerRadius = 15;
//    _select.layer.masksToBounds = YES;
//    [_select addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [header addSubview:_select];
    
    _footer = [[UIView alloc] initWithFrame:CGRectMake(0, sh-50-(bottom_h), sw, 50)];
    _footer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [window addSubview:_footer];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 50, 30)];
    _title.textAlignment = NSTextAlignmentLeft;
    _title.text = [NSString stringWithFormat:@"1/%lu",(unsigned long)_items.count];
    _title.textColor = [UIColor whiteColor];
    _title.font = [UIFont systemFontOfSize:16];
    [_footer addSubview:_title];
    
    _sure = [[UIButton alloc] initWithFrame:CGRectMake(sw-75, 10, 60, 30)];
    _sure.layer.cornerRadius = 5.0;
    _sure.layer.masksToBounds = YES;
    _sure.titleLabel.font = [UIFont systemFontOfSize:14];
    _sure.backgroundColor = [UIColor colorWithRed:235/255.0 green:37/255.0 blue:39/255.0 alpha:1];
    [_sure setTitle:[NSString stringWithFormat:@"确定(%lu)",(unsigned long)_items.count] forState:UIControlStateNormal];
    [_footer addSubview:_sure];
}
- (void)creatImgs
{
    __block CGFloat y;
    __block CGFloat h;
    for (NSInteger i = 0; i < _items.count; i++) {
        
        __block UIImage *_image;
        UIImageView *imageView = [[UIImageView alloc] init];
        JJPhotosCollectionCell *cell = _items[i];
        [self.selects addObject:@(cell.select.selected)];
        [self.selectNums addObject:@(i)];
        PHAsset *set = cell.asset;
        [[JJPhotoManager manager] fetchImageInAsset:set size:CGSizeMake(set.pixelWidth, set.pixelHeight) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            if ([[NSString stringWithFormat:@"%@",info[@"PHImageResultIsDegradedKey"]] isEqualToString:@"1"]) return;
            _image = image;
            // 设置image尺寸
            h = image.size.height*sw/image.size.width;
            y = (sh-h)/2;
            if (h > sh) y = 0;
            
            imageView.frame = CGRectMake(sw*i, y, sw-10, h);
            imageView.image = _image;
            imageView.userInteractionEnabled = YES;
            [self addSubview:imageView];
            
            UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
            click.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:click];
        }];
    }
    self.contentSize = CGSizeMake(sw*_items.count, 0);
}
- (void)click
{
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}
//- (void)selectBtn:(UIButton *)sender
//{
//    JJPhotosCollectionCell *cell = _items[_currentNum];
//    [cell selectBtnClick];
//    sender.selected = !sender.selected;
//    if (sender.selected) {
//        <#statements#>
//    }else {
//        
//    }
//}
#pragma mark scrollView代理事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int num = (int)(scrollView.contentOffset.x/sw)+1;
    self.currentNum = num-1;
    _title.text = [NSString stringWithFormat:@"%d/%lu",num,(unsigned long)_items.count];
//    if ([self.selects[_currentNum] isEqual:@(YES)]) {
//        [_select setTitle:[NSString stringWithFormat:@"%@",_selectNums[_currentNum]] forState:UIControlStateNormal];
//        _select.backgroundColor = [UIColor redColor];
//        _select.selected = YES;
//    }else {
//        [_select setTitle:@"" forState:UIControlStateNormal];
//        _select.backgroundColor = [UIColor whiteColor];
//        [_select setImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
//        _select.selected = NO;
//    }
}

@end
