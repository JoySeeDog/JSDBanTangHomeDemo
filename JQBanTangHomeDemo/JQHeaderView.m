//
//  JQHeaderView.m
//  JQScrollViewDemo
//
//  Created by jianquan on 2016/11/10.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQHeaderView.h"
#import "UIView+Extension.h"
#import "UIImage+JQImage.h"


#define NAVBAR_CHANGE_POINT 50

@interface JQHeaderView()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *emailButton;
@end

@implementation JQHeaderView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.searchBar];
        [self addSubview:self.searchButton];
        [self addSubview:self.emailButton];
        
        
    }
    return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat tableViewoffsetY = self.tableView.contentOffset.y;
    
    if ( tableViewoffsetY>=0 && tableViewoffsetY<=136) {
        
        UIColor * color = [UIColor whiteColor];
//        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - tableViewoffsetY) / 64));
            CGFloat alpha = MIN(1, tableViewoffsetY/136);
            self.backgroundColor = [color colorWithAlphaComponent:alpha];
        
        if (tableViewoffsetY < 125){
    
            [UIView animateWithDuration:0.25 animations:^{
                self.searchButton.hidden = NO;
                [self.emailButton setBackgroundImage:[UIImage imageNamed:@"home_email_black"] forState:UIControlStateNormal];
                self.searchBar.frame = CGRectMake(-(self.width-60), 30, self.width-80, 30);
                self.emailButton.alpha = 1-alpha;
                self.searchButton.alpha = 1-alpha;
                NSLog(@"alpha is %lf",alpha);
                
            }];
        } else if (tableViewoffsetY >= 125){
            
            [UIView animateWithDuration:0.25 animations:^{
                self.searchBar.frame = CGRectMake(20, 30, self.width-80, 30);
                self.searchButton.hidden = YES;
                self.emailButton.alpha = 1;
                [self.emailButton setBackgroundImage:[UIImage imageNamed:@"home_email_red"] forState:UIControlStateNormal];
            }];
        }

        
    }else if( tableViewoffsetY < 0){
       
        
    }else if (tableViewoffsetY >  136){
        
    }
}


- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-(self.width-60), 30, self.width-80, 30)];
        _searchBar.placeholder = @"搜索值得买的好物";
        _searchBar.layer.cornerRadius = 15;
        _searchBar.layer.masksToBounds = YES;

        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:_searchBar.size] forState:UIControlStateNormal];
        
        [_searchBar setBackgroundImage:[UIImage imageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] size:_searchBar.size] ];
        
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        searchField.textColor = [UIColor whiteColor];
        [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        
        
    }
    return _searchBar;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 30, 30)];
        [_searchButton setBackgroundImage:[UIImage imageNamed:@"home_search_icon"] forState:UIControlStateNormal];
       
    }
    return _searchButton;
}

- (UIButton *)emailButton {
    if (!_emailButton) {
        _emailButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width-45, 30, 30, 30)];
        [_emailButton setBackgroundImage:[UIImage imageNamed:@"home_email_black"] forState:UIControlStateNormal];
       
    }
    return _emailButton;
}



@end
