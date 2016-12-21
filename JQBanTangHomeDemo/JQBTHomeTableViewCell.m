//
//  JQBTHomeTableViewCell.m
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/23.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQBTHomeTableViewCell.h"
#import "Masonry.h"
#import "JSDTHomeRecomandModel.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface JQBTHomeTableViewCell()

@property (nonatomic, strong) UIImageView *topicimageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIImageView *pvImageView;
@property (nonatomic, strong) UILabel *pvLabel;//浏览量
@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, strong) UIView *bottomView;//用于使下面的控件整体居中



@end



@implementation JQBTHomeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.topicimageView];
         [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.bottomView];
         [self.contentView addSubview:self.authorLabel];
         [self.contentView addSubview:self.pvImageView];
         [self.contentView addSubview:self.pvLabel];
         [self.contentView addSubview:self.likeImageView];
         [self.contentView addSubview:self.likeLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_topicimageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(200);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(20);
    }];
    
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_topicimageView.mas_bottom).offset(20);
    }];
    
    
    [_authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_bottomView.mas_left);
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(15);
    }];
    
    [_pvImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_authorLabel.mas_right).offset(10);
        make.top.mas_equalTo(_authorLabel.mas_top);
        make.size.mas_equalTo(CGSizeMake(11, 11));
    }];
    
    [_pvLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_pvImageView.mas_right).offset(5);
        make.top.mas_equalTo(_authorLabel.mas_top);
    }];
    
    [_likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_pvLabel.mas_right).offset(10);
       make.top.mas_equalTo(_authorLabel.mas_top);
        make.size.mas_equalTo(CGSizeMake(11, 11));
    }];
    
    [_likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_likeImageView.mas_right).offset(5);
        make.top.mas_equalTo(_authorLabel.mas_top);
        
    }];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_authorLabel.mas_left);
        make.right.mas_equalTo(_likeLabel.mas_right);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(_authorLabel.mas_height);
    }];
    
   
}

- (void)setHomeRecomandModel:(JSDTHomeRecomandModel *)homeRecomandModel {

    [self.topicimageView sd_setImageWithURL:[NSURL URLWithString:homeRecomandModel.picUrl]  placeholderImage:homeRecomandModel.placeholderImage];
    self.titleLabel.text = homeRecomandModel.title;
    self.authorLabel.text = homeRecomandModel.author;
    self.pvLabel.text = homeRecomandModel.views;
    self.likeLabel.text = homeRecomandModel.likes;
    
}

- (UIImageView *)topicimageView {
    if (!_topicimageView) {
        _topicimageView = [[UIImageView alloc] init];
        _topicimageView.image = [UIImage imageNamed:@"recomand_01.jpg"];
    }
    return _topicimageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.text = @"测试主题";
    }
    return _titleLabel;
}


- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)authorLabel {
    if (!_authorLabel) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _authorLabel.font = [UIFont systemFontOfSize:11];
        _authorLabel.text = @"小糖君";
    }
    return _authorLabel;
}

- (UIImageView *)pvImageView {
    if (!_pvImageView) {
        _pvImageView = [[UIImageView alloc] init];
        _pvImageView.image = [UIImage imageNamed:@"home_watch"];
    }
    return _pvImageView;
}

- (UILabel *)pvLabel {
    if (!_pvLabel) {
        _pvLabel = [[UILabel alloc] init];
        _pvLabel.textColor = [UIColor grayColor];
        _pvLabel.font = [UIFont systemFontOfSize:11];
        _pvLabel.text = @"1000";
    }
    return _pvLabel;
}


- (UIImageView *)likeImageView {
    if (!_likeImageView) {
        _likeImageView = [[UIImageView alloc] init];
        _likeImageView.image = [UIImage imageNamed:@"home_like"];
    }
    return _likeImageView;
}

- (UILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[UILabel alloc] init];
        _likeLabel.textColor = [UIColor grayColor];
        _likeLabel.font = [UIFont systemFontOfSize:11];
        _likeLabel.text = @"2000";
    }
    return _likeLabel;
}

@end
