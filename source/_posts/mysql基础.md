---
layout: '[post]'
title: mysql基础
date: 2020-09-25 16:27:58
tags: mysql
categories: mysql
---

# mysql

mysql安装后默认有一个root用户，可以先使用root用于登陆
    mysql -u 用户名 -p
    mysql -u root -p

```mysql
简单使用：
显示数据库
	show databases;

自带数据库
    information_schema    mysql本身架构相关数据
    mysql    用户权限相关数据

创建数据库
    utf-8：
    create database  数据库名 default charset utf8  collate  utf8_general_ci;
    gbk：
    create database 数据库名 default  charset gbk collate utf8_chinese_ci;

使用数据库
	use 数据库名;

查看当前正在使用的数据库
	select database();

显示当前数据库中的所有表
	show tables;
```

```mysql
用户管理：
    注意：需要使用root用户
    创建用户
    create user '用户名'@'IP地址' identified by '密码';
    示例：
    create user 'alex'@'10.0.0.1' identified by 'alex1999';
    允许10.0.0.1使用alex用户登录
    create user 'alex'@'10.0.0.%' identified by 'alex1999';
    允许10.0.0.*网段使用alex用户登录
    create user 'alex'@'%' identified by 'sunck1999';
    查看：
    use mysql;
    select user,host from user;

删除用户：
	dorp user '用户名'@'IP地址';
修改用户：
	rename user '用户名'@'IP地址' to '新用户名'@'IP地址';
修改用户密码：
	set password for '用户名'@'IP地址' = password('新密码');
```

```mysql
授权管理：需要root用户
查看权限：
    show grants for '用户名'@'IP地址';
授权：
	格式：grant 权限 on 数据库.表 to '用户名'@'IP地址';

示例：
    只能对xxx数据库下的t1表进行查看和插入操作
    grant select,insert on xxx.t1 to 'sunck'@'%';
    只能对xxx数据库下的所有表进行查看和插入操作
    grant select,insert on xxx.* to 'sunck'@'%';
    添加对xxx数据库下所有表，添加grant以外的所有权限
    grant all privileges on xxx.* to 'sunck'@'%';

权限说明：详情见《权限说明》

取消授权：
	revoke 权限 on 数据库.表 from '用户名'@'IP地址';

将数据读取到内存，立即生效
	flush privileges

修改mysql的配置
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

bind-address = 127.0.0.1 --->bind-address = 0.0.0.0
```

| 权限名         | 权限说明             |
| -------------- | ------------------- |
| all privileges | 除grant外的所有权限 |
| select         | 仅查权限 |
| select,insert  | 查和插入权限 |
| usage          | 无访问权限 |
| alter          | 使用alter table |
| alter routine | 使用alter procedure和drop procedure |
| create | 使用create table |
| create routine | 使用create procedure |
| create temporary tables | 使用create temporary tables |
| create user | 使用create user、drop user、rename user和revoke  all privileges |
| create view | 使用create view |
| delete | 使用delete |
| drop | 使用drop table |
| execute | 使用call和存储过程 |
| file | 使用select into outfile 和 load data infile |
| grant option | 使用grant 和 revoke |
| index | 使用index |
| insert | 使用insert |
| lock tables | 使用lock table |
| process | 使用show full processlist |
| show databases | 使用show databases |
| show view | 使用show view |
| update | 使用update |
| reload | 使用flush |
| shutdown | 使用mysqladmin shutdown(关闭MySQL) |
| super | 使用change master、kill、logs、purge、master和set global。还允许mysqladmin调试登陆 |
| replication client | 服务器位置的访问 |
| replication slave | 由复制从属使用 |

```
字段约束：
1、primary key    主键
    作用：唯一约束标识数据库表中的每条记录
    注意：
    主键必须包含唯一的值
    主键列不能包含null值
    每个表都应该有一个主键，并且每个表只能拥有一个主键
2、not null   非空
    作用：约束强制列不能接受null值
    注意：约束强制字段始终包含值，所以如过不想字段添加值，就无法插入和更新数据
3、null     空
    作用：允许为空
4、auto_increment   自增长
    作用：自增长
    注意：对于自增长列，必须是索引(含主键)
5、default      默认值
    作用：用于向列中插入默认值
6、unique       唯一值
    作用：约束唯一标识数据库中表的每条数据
    与primary key的区别：
    a、两者均为列或列集合提供了唯一性的保证
    b、pk拥有自动定义的unique约束
    c、每个表可以有多个unique约束，但是每个表只能有一个pk约束
    使用：unique 唯一索引名称 (列名1[,……])
7、foreign key  外键
    说明：一个表中fK指向另一个表中的pk
    作用：
    a、用于用于预防破坏表之间的连接的动作
    b、也能防止非法数据插入外键列，因为它必须是它所指向的那个表中的值之一
```

```mysql
三、插入数据(增)
1、全列插入
    insert into 表名 values(值1,值2,……);
    注意：主键是自增长，但是在全列插入式需要占位，插入成功后以实际值为准
        insert into student values(0, 18, 'sunck');
        insert into student values(0, 50, '刘德华');
        insert into student values(0, 40, '刀郎');

2、缺省插入
	inset into 表名(列1,列2,……) values(值1,值2,……);
3、同时插入多条数据
    insert into 表名 values(值1,值2,……),(值1,值2,……),……;
    insert into 表名(列1,列2,……) values(值1,值2,……),(值1,值2,……),……;

四、查看数据
    select * from 表名;
    说明：
        1、from关键字后面写的表名，表示数据来源于这张表
        2、select后面写表中的列名，如果是*，表示结果中显示表中所有的列
        3、如果要查询多个列，列之间使用逗号分隔
    
五、删除表
	drop table 表名;

六、查看表结构
	desc 表名		

七、查看建表语句
    show create table 表名;     横着看
    show create table 表名 \G;  竖着看

八、重命名表名
    rename table 原表名 to 新表名;

九、清空表数据
    delete from 表名;
    truncate table 表名;
  
十、修改表
    添加列
        alter table 表名 add 列名 类型;
    删除列
        alter table 表名 drop column 列名;
    修改列
        alter table 表名 modify column 列名 类型;--类型
        alter table 表名 change 原列名 新列名 类型;--列名,类型
    添加主键
        alter table 表名 add primary key(列名);
    删除主键
        alter table 表名 drop primary key;
        #列名后的类型会修改列名的类型
        alter table 表名 modify 列名 int,drop primary key;
    添加外键
        alter table 从表 add constraint 外键名称 foreign key 从表(外键字段) references 主表(主表字段);

    外键名称：fk_从表_主表
    删除外键
        alter table 表名 drop foreign key 外键名称
    修改默认值
        alter table 表名 alter 列名 set default 100;
    删除默认值
        alter table 表名 alter 列名 drop default;

```

