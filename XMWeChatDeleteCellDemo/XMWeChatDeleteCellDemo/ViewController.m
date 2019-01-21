//
//  ViewController.m
//  XMWeChatDeleteCellDemo
//
//  Created by sfk-ios on 2019/1/21.
//  Copyright © 2019 aiq西米. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
/// 是否在编辑
@property (assign, nonatomic) BOOL isEditing;
/// 当前编辑行
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
/// 是否选择删除
@property (assign, nonatomic) BOOL isDelete;
/// 模拟数据
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.rowHeight = 60;
    
    _isEditing = NO;
    _currentIndexPath = nil;
    _isDelete = NO;
    
    self.dataArray = [NSMutableArray array];
    // 模拟数据
    for (int i = 0; i < 20; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [self.dataArray addObject:str];
    }
    [self.tableView reloadData];
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellID = @"testcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"哈哈==%@",self.dataArray[indexPath.row]];
    
    return cell;
}

#pragma mark - table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#warning iOS8~iOS10 must do methon 必须实现以下2个方法，才能左滑
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"删除");
}

/// iOS8~iOS10
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//        if (@available(iOS 11.0, *)) {
//            return nil;
//        }
    
    UITableViewRowAction *layTopRowAction1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"action1 删除");
        for (UIView *view in cell.subviews) {
//            NSLog(@"subview==%@",view);
            if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
//                NSLog(@"找到了");
                UIButton *btn = [[UIButton alloc]initWithFrame:view.bounds];
                btn.backgroundColor = [UIColor redColor];
                [btn setTitle:@"确认删除" forState:UIControlStateNormal];
                btn.tag = indexPath.row;
                // iOS8~iOS10 按钮点击有效
                [btn addTarget:self action:@selector(sureDeleteAction) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
                self.isDelete = YES;
                _currentIndexPath = indexPath;
            }
        }
    }];
    
    UITableViewRowAction *layTopRowAction2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"取消关注" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // 处理 取消关注
        NSLog(@"action2 取消关注");
        [tableView setEditing:NO animated:YES];
        
    }];
    layTopRowAction1.backgroundColor = [UIColor orangeColor];
    layTopRowAction2.backgroundColor = [UIColor blueColor];
    
    NSArray *arr = @[layTopRowAction1,layTopRowAction2];
    return arr;
}


#ifdef __IPHONE_11_0
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{

#warning 注意 ios 11 +
    if (@available(iOS 11.0, *)) {

        UIContextualAction *action1 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

            if (self.isEditing && self.isDelete) {
                NSLog(@"action1 处理删除");
                _currentIndexPath = indexPath;
                [self sureDeleteAction];

            }else {

                NSLog(@"action1 删除");
                for (UIView *view in self.tableView.subviews) {
//                    NSLog(@"subview==%@",view);
                    if ([view isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
//                        NSLog(@"找到了");
                        UIButton *btn = [[UIButton alloc]initWithFrame:view.bounds];
                        btn.backgroundColor = [UIColor redColor];
                        [btn setTitle:@"确认删除" forState:UIControlStateNormal];
                        btn.tag = indexPath.row;
                        // 点击无效，应该是 UISwipeActionPullView 机制,事件穿透,待研究
                        //                    [btn addTarget:self action:@selector(sureDeleleAction) forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                        self.isDelete = YES;
                    }
                }
//                NSLog(@"sourceView==%@",sourceView);
            }

        }];

        UIContextualAction *action2 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消关注" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if (self.isEditing && self.isDelete) { // 处理删除
                NSLog(@"action2 处理删除");
                _currentIndexPath = indexPath;
                [self sureDeleteAction];
            }else {
                // 处理 取消关注
                NSLog(@"action2 取消关注");
                [tableView setEditing:NO animated:YES];
            }
        }];

        action1.backgroundColor = [UIColor orangeColor];
        action2.backgroundColor = [UIColor blueColor];

        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[action1,action2]];
        actions.performsFirstActionWithFullSwipe = NO; // 禁止右滑充满整个Cell

        return actions;
    }
    return nil;
}
#endif


/// 确认删除
- (void)sureDeleteAction{
    
    if (_currentIndexPath) {
        NSLog(@"确认删除 _currentIndexPath.row==%ld",_currentIndexPath.row);
        [self.dataArray removeObjectAtIndex:_currentIndexPath.row];
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
    }
}

// 即将开始编辑cell
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isEditing = YES;
    self.currentIndexPath = indexPath;
    self.isDelete = NO;
//    NSLog(@"willBeginEditingRowAtIndexPath");
}

// 结束编辑cell
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    
    self.isEditing = NO;
    self.currentIndexPath = nil;
//    NSLog(@"didEndEditingRowAtIndexPath");
}

@end
