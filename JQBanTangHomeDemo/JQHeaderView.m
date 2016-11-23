//
//  JQHeaderView.m
//  JQScrollViewDemo
//
//  Created by jianquan on 2016/11/10.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQHeaderView.h"
#import "UIView+Extension.h"

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
        
    }else if( tableViewoffsetY < 0){
        
    }else if (tableViewoffsetY > 136){
    }
}


- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 30, self.width-80, 30)];
        _searchBar.placeholder = @"搜索值得买的好物";
        _searchBar.layer.cornerRadius = 15;
        _searchBar.layer.masksToBounds = YES;

        [_searchBar setSearchFieldBackgroundImage:[self imageWithColor:[UIColor clearColor] size:_searchBar.size] forState:UIControlStateNormal];
        
        [_searchBar setBackgroundImage:[self imageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] size:_searchBar.size] ];
        
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        searchField.textColor = [UIColor redColor];
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
