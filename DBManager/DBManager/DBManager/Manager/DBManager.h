//
//  DBManager.h
//  DBManager
//
//  Created by A.B.T. on 16/6/22.
//  Copyright © 2016年 A.B.T. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBManager : NSObject

/**
 *  单例方法
 */
+ (instancetype)shareManager;

/**
 *  创建表
 *
 *  @param T_name     表名称
 *  @param modelClass  model 类型
 */
- (void)creatTableWithTableName:(NSString *) T_name andModel:(Class) modelClass;

/**
 *  插入模型数据
 *
 *  @param T_name 所插入的表名称
 *  @param model  模型数据（简单模型 暂不支持复杂模型）
 */
- (void)insertDataForTableName:(NSString *)T_name WithModel:(id) model;

/**
 *  查询数据
 *
 *  @param T_name 表名称
 *
 *  @return 模型数组
 */
- (NSArray *)queryDataForTable:(NSString *)T_name;

/**
 *  删除表数据（delete）
 *
 *  @param T_name 表名称
 */
- (void)deleteDataForTable:(NSString *)T_name;

/**
 *  删除单行表数据
 *
 *  @param T_name   表名称
 *  @param flagDict 标记位
 */
- (void)deleteForRowOfTable:(NSString *)T_name flagDictionary:(NSDictionary *) flagDict;

/**
 *  删除表
 *
 *  @param T_name 表名称
 */
- (void)deleteTable:(NSString *)T_name;

/**
 *  更新数据
 *
 *  @param T_name     表名称
 *  @param updateDict 更新位 key / value
 *  @param flagDict   标记位 key / value
 */
- (void)updateDataForTable:(NSString *)T_name  updateDictionary:(NSDictionary *)updateDict  flagDictionary:(NSDictionary *)flagDict;

/**
 *  更新数据
 *
 *  @param  sql语句
 */
- (void)updateDataBaseSQL:(NSString *) sql;


@end


