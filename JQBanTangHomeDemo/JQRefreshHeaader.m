//
//  JQRefreshHeaader.m
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/21.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQRefreshHeaader.h"

NSString *const JQTableKeyPathContenOffSet = @"contentOffset";

@interface  JQRefreshHeaader()
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation JQRefreshHeaader

- (instancetype)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.refreshImageView];
    }
    
    return self;
    
}



- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_tableView addObserver:self forKeyPath:JQTableKeyPathContenOffSet options:options context:nil];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat tableViewoffsetY = self.tableView.contentOffset.y;
    
    if ( tableViewoffsetY <= 0  &&tableViewoffsetY > -35) {
        [self hideAllImageView];
        if (self.refreshImageView.isAnimating) {
            [self.refreshImageView stopAnimating];
        }
        
        
    }else if(tableViewoffsetY < -35){
       
        CGFloat offset = 0;
        if (tableViewoffsetY < -59) {
            offset = 24;
            [self showAllImageView];
        }else {
            offset = fabs(tableViewoffsetY)-35;
        }
        
        NSInteger imageCount = offset/2.0;
        [self hideImageViewExcept:imageCount];
      
    }else if (tableViewoffsetY <136){
        
    }
    
    if (tableViewoffsetY<-64 && !self.tableView.isDragging) {
//        [self hideAllImageView];
//        [self.refreshImageView startAnimating];
    }
    
}

- (void)showAllImageView {
    
    for (int i = 0; i<self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        imageView.hidden = NO;
        
    }
}

- (void)hideAllImageView {
    
    for (int i = 0; i<self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        imageView.hidden = YES;
        
    }
}

//隐藏其他图片除了当前的图片
- (void)hideImageViewExcept:(NSInteger)index {
    
    if (index>=[self.imageViews count]) {
        return;
    }
    
    for (int i = 0; i<self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        if (i==index) {
            imageView.hidden = NO;
        }else {
            imageView.hidden = YES;
        }
    }
}


//- (UIImageView *)refreshImageView {
//    if (!_refreshImageView) {
//        _refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//        _refreshImageView.center = self.center;
//        NSMutableArray *imageArray = [NSMutableArray array];
//        for (int i= 1;i<11;i++){
//            
//            NSString *imageUrl  = [NSString stringWithFormat:@"refresh%02d",i];
//            UIImage *image = [UIImage imageNamed:imageUrl];
//            [imageArray addObject:image];
//        }
//        _refreshImageView.animationImages = imageArray;
//        _refreshImageView.animationDuration = 0.25;
//        _refreshImageView.animationRepeatCount = 1;
//        
//    }
//    return _refreshImageView;
//}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
        for (int i= 1;i<11;i++){
        
            NSString *imageUrl  = [NSString stringWithFormat:@"header%02d%@",i,@"@2x.jpg"];
            UIImage *image = [UIImage imageNamed:imageUrl];
            UIImageView *imageView  =[ [UIImageView alloc] initWithFrame:self.bounds];
            imageView.image = image;
            imageView.hidden = YES;
            [_imageViews addObject:imageView];
            [self addSubview:imageView];
        }
        
    }
    return _imageViews;
}

@end
