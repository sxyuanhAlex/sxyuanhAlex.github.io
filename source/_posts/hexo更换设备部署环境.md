---
layout: 'n'
title: hexo更换设备部署环境
date: 2019-09-20 15:57:59
tags: hexo
categories: hexo

---

## 一、多设备同步
+ Github新建一个分支--hexo
使用git指令将带hexo配置的Github工程文件上传到新建的分支上。
```
在本地博客根目录下使用git指令上传项目到Github:
// git初始化
git init
// 添加仓库地址
git remote add origin https://github.com/用户名/仓库名.git
// 新建分支并切换到新建的分支
git checkout -b 分支名
// 添加所有本地文件到git
git add .
// git提交
git commit -m ""
// 文件推送到hexo分支
git push origin hexo
```
## 二、前提条件
+ 安装git
+ 安装node.js
+ hexo个人博客

```
npm install hexo -g
npm install
npm --save install hexo-deployer-git
```
+ 设置Git的user name 和email
```
git config --global user.name 名字
git config --global user.email 邮箱
```
+ 输入如下指令，连续三个回车，生成密钥，最后得到了两个文件：id_rsa和id_rsa.pub（默认存储路径是：C:\Users\Ericam\.ssh）。
```
ssh-keygen -t rsa -C "你的邮箱"
```
打开id_rsa.pub文件复制全部内容。
进入github账户的setting界面，进入SSH and GPG Keys目录，删除原来的SSH，新建SSH

## 三、坑点
1. **主题文件夹上传不到github上**

主题文件夹是空的
而自己本地的主题文件夹是有文件的

+ 探索
大家可能想到是因为.gitignore里面忽略了这两个文件夹下的所有文件，但是经过自己的检查，发现并不是这儿的问题
### **真正的解决办法**
经过多番探索，终于找到了症结，先来说如何解决

凡是通过git clone从github上拉取的代码，删除除了项目根目录以外的任何位置的 .git文件夹，.gitignore (或者编辑这个文件夹，删除那些你想上传但是被忽略的文件或文件夹) 和 .github 文件夹
操作完成之后，用SourceTree还是看不到需要上传的主题文件在“未暂存文件”一栏中，不要失望接着往下看
还要删除掉 SourceTree 中的 主题 子模块 ，如下图：
![](/images/submodule.png)
删除时，一定要勾选 “强制删除” ，要不然会删除不掉，而且SourceTree报错
![](/images/force_delete.png)

出现此问题的原因
主要根源是每次我们下载主题时，都会用git命令clone源代码，例如像这样：
```
$ git clone --branch v5.1.2 https://github.com/xxxx/xxxxx themes/next
```
最终导致自己的主题文件夹下多了个.git文件夹，会被认为是另一个资源库，从属于自己的项目之下，在SourceTree中显示成“子模块”，而这些项目需要的主题文件不会被push到自己的github仓库中。


## 四、git clone git@github.com:xxxx/xxxxx
**执行hexo s的时候报error, Cannot find module './db.json'**
解决方法
```
copy别人的 \node_modules\mime-db\db.json
在别的目录下，执行npm install mime-db，然后把生成的db.json拷贝过去
```

