//
//  DBManager.m
//  DBManager
//
//  Created by A.B.T. on 16/6/22.
//  Copyright © 2016年 A.B.T. All rights reserved.
//

#import "DBManager.h"
#import "FMDB.h"
#import "PropertyConstant.h"
#import <objc/runtime.h>

#define APPLICATION_DB_NAME     (@"Appliaction") // 数据库名称
#define DB_MODEL_TYPE (@"modelType")


@interface PropertyModel : NSObject
@property (nonatomic, copy) NSString *propertyName;///< 属性名
@property (nonatomic, copy) NSString*propertyAttribute;///< 属性类型
@property (nonatomic, copy) NSString *sqlAttribute;///< 数据库类型
@end
@implementation PropertyModel
@end



@implementation DBManager {
    FMDatabaseQueue *_dbQueue; //< 队列
    FMDatabase *_db;
}

#pragma mark - /*** 单例方法 ***/
+ (instancetype)shareManager {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    
    return _instance;
}

#pragma mark - /*** 初始化方法 ***/
- (instancetype)init {
    if (self = [super init]) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self getDataBasePathWithName:APPLICATION_DB_NAME]];
        _db = [FMDatabase databaseWithPath:[self getDataBasePathWithName:APPLICATION_DB_NAME]];
    }
    return self;
}

#pragma mark - /*** 获取数据库路径 ***/
- (NSString *)getDataBasePathWithName:(NSString *) dbName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    
    return dbPath;
}

#pragma mark - /*** 创建表 ***/
- (void)creatTableWithTableName:(NSString *) T_name andModel:(Class) modelClass {
    
    NSArray <PropertyModel *>*propertys = [self getPropertyOfModel:[modelClass new]];
    // 准备SQL
    NSMutableString *creatSQL = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ Text,",
                                 T_name,
                                 [NSString stringWithFormat:@"%@_id",T_name],
                                 DB_MODEL_TYPE
                                 ];
    
    [propertys enumerateObjectsUsingBlock:^(PropertyModel * property, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == propertys.count - 1) {
            [creatSQL appendFormat: @" %@ %@)",property.propertyName,property.sqlAttribute];
        }else {
            [creatSQL appendFormat: @" %@ %@,",property.propertyName,property.sqlAttribute];
        }
    }];
    
    // 执行SQL
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSucceed = [db executeStatements:creatSQL.copy];
        if (isSucceed) {
            NSLog(@"创表成功:%@",T_name);
        }else {
            NSLog(@"创表失败:%@",T_name);
        }
    }];
    
}

#pragma mark - /*** 更新数据 ***/
- (void)updateDataForTable:(NSString *)T_name  updateDictionary:(NSDictionary *)updateDict  flagDictionary:(NSDictionary *)flagDict{

//    UPDATE Person SET FirstName = 'Nina'  WHERE LastName = 'Rasmussen'
    
    NSArray *updateAllKeys = updateDict.allKeys;
    NSArray *updateAllValues = updateDict.allValues;
    
    NSArray *flagAllKeys = flagDict.allKeys;
    NSArray *flagAllValues = flagDict.allValues;
    
    if (updateAllValues.count != flagAllValues.count) {
        NSLog(@"请检查参数");
        return;
    }
    
    // 打开数据库
    [_db open];
    
    [updateAllKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 准备SQL
        NSString * updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@'",
                                                                                                                                                                                            T_name,
                                                                                                                                                                                            updateAllKeys[idx],
                                                                                                                                                                                            updateAllValues[idx],
                                                                                                                                                                                            flagAllKeys[idx],
                                                                                                                                                                                            flagAllValues[idx]
                                                                                                                                                                                            ];
        // 执行SQL
        BOOL isSucceed = [_db executeUpdate:updateSQL];
        
        if (isSucceed) {
            NSLog(@"更新数据成功");
        }else {
            NSLog(@"更新数据库失败");
        }
        
    }];
    
    // 关闭数据库
    [_db close];
    
}


- (void)updateDataBaseSQL:(NSString *) sql {

    [_db open];
    
    BOOL isSucceed = [_db executeUpdate:sql];
    if (isSucceed) {
        NSLog(@"更新数据成功");
    }else {
        NSLog(@"更新数据库失败");
    }
    
    [_db close];

}

#pragma mark - /*** 删除表 ***/
- (void)deleteTable:(NSString *)T_name {
    // 准备SQL
    NSString *dTSQL = [NSString stringWithFormat:@"DROP TABLE %@",T_name];
    // 打开数据库
    [_db open];
    
    BOOL isSucceed =  [_db executeUpdate:dTSQL];
    if (isSucceed) {
        NSLog(@"删表成功");
    }else {
        NSLog(@"删表失败");
    }
    
    // 关闭数据库
    [_db close];
    
}

#pragma mark - /*** 删除表数据 ***/
- (void)deleteDataForTable:(NSString *)T_name {
    
    // 准备SQL
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@",T_name];
    // 打开数据库
    [_db open];
    // 执行SQL
    BOOL isSucceed =  [_db executeUpdate:deleteSQL];

    if (isSucceed) {
        NSLog(@"删除表数据成功");
    }else {
        NSLog(@"删除表数据失败");
    }
    // 关闭数据库
    [_db close];
}

#pragma mark - /*** 删除一行表数据 ***/
- (void)deleteForRowOfTable:(NSString *)T_name flagDictionary:(NSDictionary *) flagDict {
    
    // 打开数据库
    [_db open];
    
    //  准备SQL delete from ms_cf01 where brxm='张三' and id='7598';
    __block NSMutableString *deleteSQL = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE ",T_name];
    [flagDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [deleteSQL appendFormat:@"%@= '%@' and",key,obj];
    }];
    
     NSRange range =  [deleteSQL rangeOfString:@"and" options:NSBackwardsSearch];
    
    NSString *deleteSql  = [deleteSQL substringWithRange:NSMakeRange(0, range.location)];
    
    // 执行SQL
   BOOL isSucceed =  [_db executeUpdate: deleteSql];
    
    if (isSucceed) {
        NSLog(@"单行删除成功");
    }else {
        NSLog(@"单行删除失败");
    }
    
    
    // 关闭数据库
    [_db close];
}

#pragma mark - /*** 查询数据 ***/
- (NSArray *)queryDataForTable:(NSString *)T_name{
    if (![self isExistTable:T_name]) {
        return nil;
    }
    // 准备SQL
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@",T_name];
    NSMutableArray *tempArray = [NSMutableArray array];
    // 执行SQL
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet  = [db executeQuery:querySQL];
        if (!resultSet) {
            NSLog(@"查询错误");
            return ;
        }
        
        while ([resultSet next]) {
            // 获取model 类型
            NSString *modelClass = [resultSet stringForColumn:DB_MODEL_TYPE];
            // 生成class
            Class class = NSClassFromString(modelClass);
            // 实例模型
            id T_model = [[class alloc] init];
            // 获取模型属性
            NSArray <PropertyModel *> * propertys = [self getPropertyOfModel:T_model];
            
            [propertys enumerateObjectsUsingBlock:^(PropertyModel * _Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([pModel.propertyAttribute containsString: PropertyTypeString] ) { // 字符串类型
                    [T_model setValue:[resultSet stringForColumn:pModel.propertyName] forKey:pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeBool]){ // 布尔值
                    [T_model setValue:[NSNumber numberWithBool:[resultSet boolForColumn:pModel.propertyName]] forKey:pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeInt]) { // int 类型
                    [T_model setValue:[NSNumber numberWithInt:[resultSet intForColumn:pModel.propertyName] ]forKey:pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeCGFloat]) { // CGFloat
                    [T_model setValue:[NSNumber numberWithDouble:[resultSet doubleForColumn:pModel.propertyName]] forKey: pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeInterger]) { //NSinteger
                    [T_model setValue:[NSNumber numberWithInteger:[resultSet longForColumn:pModel.propertyName]] forKey:pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeFloat]) { // float
                    [T_model setValue:[NSNumber numberWithFloat:[resultSet doubleForColumn:pModel.propertyName ]] forKey:pModel.propertyName];
                }else if ([pModel.propertyAttribute containsString:PropertyTypeImage]) { // UIImage
                    [T_model setValue:[resultSet objectForColumnName:pModel.propertyName] forKey:pModel.propertyName];
                }
            }];
            
            [tempArray addObject: T_model];
            
        }
        
    }];
    
    return tempArray.copy;
}



#pragma mark - /*** 插入数据库 ***/
- (void)insertDataForTableName:(NSString *)T_name WithModel:(id) model {
    
    if (![self isExistTable:T_name]) { // 表不存在  则创建表
        [self creatTableWithTableName:T_name andModel:model];
    }
    
    if ([self getModelTypeOfTable:T_name]) { // 已存在数据
        if (![NSStringFromClass([model class]) isEqualToString: [self getModelTypeOfTable:T_name]] ) {
            NSLog(@"\n数据插入失败, 请检查Model 类型,\n modelType ：%@",[self getModelTypeOfTable: T_name]);
            return;
        }
    }
    
    // 准备SQL
    NSMutableString *prefixSQL = [NSMutableString stringWithFormat:@"INSERT INTO %@ (%@,",T_name,DB_MODEL_TYPE];
    NSMutableString *suffixSQL = [NSMutableString stringWithFormat:@"VALUES (?,"];
    
    // 获取模型属性
    NSArray <PropertyModel *> *propertys = [self getPropertyOfModel:model];
    // 获取模型属性值
    NSArray <NSObject *>* propertyValues = [self getPropertyValueForCurrentModel:model];
    NSMutableArray <NSObject *>* pValues = [NSMutableArray arrayWithObject:[model class]];
    [pValues addObjectsFromArray:propertyValues];
    
    [propertys enumerateObjectsUsingBlock:^(PropertyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == propertys.count -1) {
            
            [prefixSQL appendFormat:@"%@) ",obj.propertyName];
            [suffixSQL appendFormat:@"?)"];
        }else {
            [prefixSQL appendFormat:@"%@,",obj.propertyName];
            [suffixSQL appendFormat:@"?,"];
        }
        
    }];
    
    //  插入SQL 语句
    NSString *insertSQL = [NSString stringWithFormat:@"%@ %@",prefixSQL.copy,suffixSQL.copy];
    NSLog(@"%@",insertSQL);
    
    // 执行SQL
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        NSError *error = [NSError new];
        
        BOOL isSucceed = [db executeUpdate:insertSQL values:pValues error:&error];
        
        if (isSucceed) {
            NSLog(@"数据插入成功");
        }else {
            NSLog(@"数据插入失败: %@",error);
        }
        
    }];
    
}

#pragma mark - /*** 查看表是否存在 ***/
- (BOOL) isExistTable:(NSString *)T_name{
    [_db open];
    FMResultSet *rs = [_db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", T_name];
    while ([rs next]){
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count){
            [_db close];
            NSLog(@"不存在表:%@",T_name);
            return NO;
        }else{
            [_db close];
            NSLog(@"存在表:%@",T_name);
            return YES;
        }
    }
    NSLog(@"不存在表:%@",T_name);
    [_db close];
    return NO;
}


#pragma mark - /*** 获取属性值 ***/
- (NSArray *)getPropertyValueForCurrentModel:(id) model{
    //获取实体类的属性
    NSArray <PropertyModel *> *propertyArray = [self getPropertyOfModel:model];
    NSMutableArray  * propertyValues = [NSMutableArray arrayWithCapacity:propertyArray.count];
    [propertyArray enumerateObjectsUsingBlock:^(PropertyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSValue *propertyValue = [model valueForKey: obj.propertyName];
        if (propertyValue) {
            [propertyValues addObject:propertyValue];
        }
        
    }];
    
    return propertyValues.copy;
}

#pragma mark - /*** 获取当前表的模型类型 ***/
- (NSString *)getModelTypeOfTable:(NSString *) T_name {
    
    NSString *checkSql = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1",T_name];
    __block NSString * modelType = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:checkSql];
        if (!resultSet) {
            NSLog(@"查询失败");
            return ;
        }
        
        while ([resultSet next]) {
            modelType = [resultSet stringForColumn:DB_MODEL_TYPE];
        }
        
    }];
    
    return modelType;
};


#pragma mark - /*** 获取模型属性 名称／类型 ***/
- (NSArray <PropertyModel *> *)getPropertyOfModel:(id) model {
    //  存储所有属性名称
    NSMutableArray < PropertyModel*>* propertyArray = [NSMutableArray array];
    
    ///存储属性的个数
    unsigned int propertyCount = 0;
    // 获取模型属性
    objc_property_t *propertys = class_copyPropertyList([model class], &propertyCount);
    
    for (int i = 0; i< propertyCount; i++) {
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        const char *propertyAttrbute = property_getAttributes(property);
        
        PropertyModel *pModel = [PropertyModel new];
        
        NSString *pName = [NSString stringWithUTF8String:propertyName];
        NSString *pAttribute = [NSString stringWithUTF8String:propertyAttrbute];
        
        pAttribute  = [pAttribute componentsSeparatedByString:@","].firstObject;
        
        NSString *sqlAttribute ;
        if ([pAttribute containsString:PropertyTypeString]) { // NSString
            sqlAttribute = @"TEXT";
        }else if ([pAttribute containsString:PropertyTypeBool]) { // BOOL
            sqlAttribute = @"Integer";
        }else if ([pAttribute containsString:PropertyTypeCGFloat]) { // CGFloat
            sqlAttribute = @"Double";
        }else if ([pAttribute containsString:PropertyTypeInt]) { // Int
            sqlAttribute = @"Integer";
        }else if ([pAttribute containsString:PropertyTypeInterger]) { // NSInterger
            sqlAttribute = @"Long";
        }else if ([pAttribute containsString:PropertyTypeFloat]) { //Float
            sqlAttribute = @"Single";
        }else if ([pAttribute containsString:PropertyTypeImage]) { // UIImage
            sqlAttribute = @"Ole Object";
        }
        
        pModel.sqlAttribute = sqlAttribute;
        pModel.propertyAttribute = pAttribute;
        pModel.propertyName = pName;
        [propertyArray addObject:pModel];
    }
    // 释放
    free(propertys);
    return propertyArray.copy;
}

@end



