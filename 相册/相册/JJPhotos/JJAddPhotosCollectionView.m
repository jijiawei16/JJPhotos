//
//  JJAddPhotosCollectionView.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJAddPhotosCollectionView.h"
#import "JJAddPhotoCollectionViewCell.h"
#import "JJPhotosViewController.h"

@interface JJAddPhotosCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegate>

// 数据源
@property (nonatomic , strong , readwrite) NSMutableArray *items;
// 长按手势
@property (nonatomic , strong) UILongPressGestureRecognizer *longPress;
// 当前选中的cell
@property (nonatomic , strong) JJAddPhotoCollectionViewCell *current;
// 当前cell的移动裁剪视图
@property (nonatomic , strong) UIView *move;
// 当前移动视图的中心点
@property (assign, nonatomic) CGPoint currentPoint;
@end
@implementation JJAddPhotosCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.maxCount = 6; // 设置默认最大图片数为6
        self.rows = 3; // 设置每一行的图片最大数
        self.showDelect = YES; // 默认显示删除按钮
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.items = [NSMutableArray array];
        [self addGestureRecognizer:self.longPress];
        [self registerClass:[JJAddPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"JJAddPhotoCollectionViewCell"];
        
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)addItems:(NSArray *)items
{
    if (!items.count) return;
    [_items addObjectsFromArray:items];
    [self reloadData];
    [self changeItmes:-1];
}
- (NSArray *)getItems
{
    return self.items;
}
- (void)changeItmes:(NSInteger)index
{
    // 数据源添加图片
    if ([self.jj_delegate respondsToSelector:@selector(JJAddPhotosCollectionView:Changeitems:index:)]) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSInteger i = 0; i < self.items.count; i++) {
            NSData *imageData;
            if ([self.items[i] isKindOfClass:[NSString class]]) {
                NSString *str = (NSString *)self.items[i];
                imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:str]];
            }else {
                UIImage *image = (UIImage *)self.items[i];
                imageData = UIImageJPEGRepresentation(image,0.1);
            }
            NSString *encodedString = [imageData base64Encoding];
            if (encodedString) {
                [temp addObject:encodedString];
            }else{
                [temp addObject:@""];
            }
            
        }
        [self.jj_delegate JJAddPhotosCollectionView:self Changeitems:temp index:index];
    }
}
#pragma mark 数据源
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.items.count < self.maxCount) {
        return self.items.count+1;
    }
    return self.maxCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = @"JJAddPhotoCollectionViewCell";
    JJAddPhotoCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row == self.items.count) {
        [cell setUpImage:[UIImage imageNamed:@"添加图片"]];
    }else{
        if (self.showDelect) {
            if ([self.items[indexPath.row] isKindOfClass:[NSString class]]) {
                [cell setUpImageUrl:self.items[indexPath.row] callBack:^{
                    [self.items removeObjectAtIndex:indexPath.row];
                    [self reloadData];
                    [self changeItmes:indexPath.row];
                }];
            }else {
                [cell setUpImage: self.items[indexPath.row] callBack:^{
                    [self.items removeObjectAtIndex:indexPath.row];
                    [self reloadData];
                    [self changeItmes:indexPath.row];
                }];
            }
        } else {
            if ([self.items[indexPath.row] isKindOfClass:[NSString class]]) {
                [cell setUpImageUrl:self.items[indexPath.row]];
            }else {
                [cell setUpImage:self.items[indexPath.row]];
            }
        }
    }
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.maxCount) {
        return NO;
    }
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.items.count == self.maxCount) {// 判断是否达到最大数
        if ([self.jj_delegate respondsToSelector:@selector(JJAddPhotosCollectionView:didSelectIndex:)]) {
            [self.jj_delegate JJAddPhotosCollectionView:self didSelectIndex:indexPath.row];
        }
    }else if (indexPath.row == self.items.count){// 如果没有达到最大数，最后一张就是添加按钮
        if (self.superVC) {
            JJPhotosViewController *photoVC = [[JJPhotosViewController alloc] initWithcallBack:^(NSArray *images) {
                NSLog(@"%@",images);
                [self.items addObjectsFromArray:images];
                [self reloadData];
                [self changeItmes:-1];
            }];
            photoVC.maxCount = self.maxCount-self.items.count;
            [self.superVC presentViewController:photoVC animated:YES completion:nil];
        }
    }else {// 其余的都是点击了图片事件
        if ([self.jj_delegate respondsToSelector:@selector(JJAddPhotosCollectionView:didSelectIndex:)]) {
            [self.jj_delegate JJAddPhotosCollectionView:self didSelectIndex:indexPath.row];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath{
    
    if (destinationIndexPath.row == self.maxCount) {
        return;
    }
    NSInteger from = sourceIndexPath.row;
    NSInteger to = destinationIndexPath.row;
    
    // 交换数据
    if (from > to) {
        
        for (NSInteger i = from; i > to; i--) {
            [self.items exchangeObjectAtIndex:i withObjectAtIndex:i-1];
        }
    }else{
        
        for (NSInteger i = from; i < to; i++) {
            [self.items exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
    }
    [self changeItmes:-1];
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.frame.size.width/self.rows, self.frame.size.width/self.rows);
}
#pragma mark - 长按手势方法
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            
            NSIndexPath *selectIndexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (selectIndexPath.row == self.items.count) {
                break;
            }
            [self beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
            
            //获取手指所在的cell,并将cell信息保存,裁剪cell为一个移动视图,并隐藏cell
            JJAddPhotoCollectionViewCell *cell = (JJAddPhotoCollectionViewCell *)[self cellForItemAtIndexPath:selectIndexPath];
            self.current = cell;
            self.move = [cell snapshotViewAfterScreenUpdates:NO];
            cell.hidden = YES;
            _move.frame = [self.current convertRect:self.current.bounds toView:self.superVC.view];
            _move.transform = CGAffineTransformMakeScale(1.1, 1.1);
            [self.superVC.view addSubview:_move];
            _currentPoint = [self.longPress locationOfTouch:0 inView:self.longPress.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGFloat tranX = [self.longPress locationOfTouch:0 inView:self.longPress.view].x - _currentPoint.x;
            CGFloat tranY = [self.longPress locationOfTouch:0 inView:self.longPress.view].y - _currentPoint.y;
            _move.center = CGPointApplyAffineTransform(_move.center, CGAffineTransformMakeTranslation(tranX, tranY));
            _currentPoint = [self.longPress locationOfTouch:0 inView:self.longPress.view];
            
            NSIndexPath *selectIndexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (selectIndexPath.row == self.items.count) {
                break;
            }
            [self updateInteractiveMovementTargetPosition:[longPress locationInView:longPress.view]];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.3 animations:^{
                    _move.frame = [self.current convertRect:self.current.bounds toView:self.superVC.view];
                } completion:^(BOOL finished) {
                    [_move removeFromSuperview];
                    self.current.hidden = NO;
                    self.userInteractionEnabled = YES;
                }];
            });
            [self endInteractiveMovement];
            break;
        }
        default:
            [self cancelInteractiveMovement];
            break;
    }
}
#pragma mark kvo监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        if ([self.jj_delegate respondsToSelector:@selector(JJAddPhotosCollectionView:ChangeFrame:)]) {
            CGRect self_frame = self.frame;
            self_frame.size.height = self.contentSize.height;
            self.frame = self_frame;
            [self.jj_delegate JJAddPhotosCollectionView:self ChangeFrame:self.frame];
        }
    }
}
#pragma mark 懒加载
- (UILongPressGestureRecognizer *)longPress
{
    if (_longPress == nil) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    }
    return _longPress;
}
@end

