# TDengine on Kubernetes

- Author: Huo Linhe <lhhuo@taosdata.com>
- Updated：2021-06-09 16:24:00

This document is for [TDengine] deployment on [Kubernetes(k8s)][K8s]. All the things we do is for who love [TDengine] and want to take it to k8s. We are hosting the ducumentation on [taosdata/TDengine-Operator](https://github.com/taosdata/TDengine-Operator). Anyone want to help improve the ducumentations could edit the markdown files.

If you encounter problems following the operations, you can always add our official WeChat "tdengine" to join our chat group to get help from us and other TDengine users.

[TDengine]: https://github.com/taosdata/TDengine
[K8s]: https://kubernetes.io/



# 本项目基于[taosdata/TDengine-Operator](https://github.com/taosdata/TDengine-Operator)

### 代码仓库管理方式
- 1. 项目从github上fork过来后，会提交一个副本到codeup上。
- 2. 从上游仓库[taosdata/TDengine-Operator](https://github.com/taosdata/TDengine-Operator)同步的代码，都只能读，不能写。如果要修改代码，都需要建立一个新分支提交，不能直接提交到上游仓库同步过来的分支里。
- 3. 由于本项目需要根据上游仓库代码做定制，所以针对不同的运行环境采用不同的分支来管理代码，各环境对应的分支如下：
  
      |运行环境|分支名称|
      |----|----|
      |开发|develop-yw|
      |预发布|release-yw|
      |生产环境|main-yw|

- 4. 如果上游仓库有代码更新，可将其同步下来，按需要合并到自建的分支代码里。 