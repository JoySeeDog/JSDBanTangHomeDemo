//
//  JSDTableViewController.m
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/12/14.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JSDTableViewController.h"
#import "JQBTHomeTableViewCell.h"
#import "JSDTHomeRecomandModel.h"

@interface JSDTableViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation JSDTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view addSubview:self.tableView];
        [self loadData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JQBTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JQBTHomeTableViewCell class])];
    
    cell.homeRecomandModel = [self.modelArray objectAtIndex:indexPath.row];
    return cell;
}


- (void)loadData {
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSArray * dataArray = [[dic objectForKey:@"data"] objectForKey:@"topic"];
        
        
        [self.modelArray removeAllObjects];
        for (unsigned long i = 0; i<[dataArray count]; i++) {
            JSDTHomeRecomandModel *model = [[JSDTHomeRecomandModel alloc] init];
            NSString *string = [NSString stringWithFormat:@"recomand_%02ld%@",i+1,@".jpg"];
            UIImage *image  = [UIImage imageNamed:string];
            
            model.placeholderImage = image;
            
            NSDictionary *itemDic = dataArray[i];
            model.picUrl = [itemDic objectForKey:@"pic"];
            model.title = [itemDic objectForKey:@"title"];
            model.views = [itemDic objectForKey:@"views"];
            model.likes = [itemDic objectForKey:@"likes"];
            
            NSDictionary *userDic = [itemDic objectForKey:@"user"];
            model.author = [userDic objectForKey:@"nickname"];
            
            [self.modelArray addObject:model];
            
        }
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
//        });
    
        
//    });
}




- (UITableView *)tableView {
    if (!_tableView) {
        _tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[JQBTHomeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JQBTHomeTableViewCell class])];
        
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 242)];
        tableHeaderView.backgroundColor = [UIColor whiteColor];
        
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(182, 0, 0, 0);
        _tableView.tableHeaderView = tableHeaderView;
       
        
        
    }
    return _tableView;
}

- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}


@end
