---
layout: '[post]'
title: Django REST framework的认证方式及自定义认证
date: 2019-09-18 10:00:00
tags:
- Django
categories: python
---

# 源码剖析Django REST framework的认证方式及自定义认证


## 源码剖析Django REST framework的认证方式

由Django的CBV模式流程，可以知道在`url匹配完成后，会执行自定义的类中的as_view方法`。

如果自定义的类中没有定义`as_view方法`，根据面向对象中类的继承可以知道，则`会执行其父类View中的as_view方法`

`在Django的View的as_view方法中，又会调用dispatch方法`。

现在来看看Django restframework的认证流程

> Django restframework是基于Django的框架，所以基于CBV的模式也会执行自定义的类中的as_view方法

先新建一个项目，配置url

```python
from django.conf.urls import url
from django.contrib import admin

from app01 import views

urlpatterns = [
    url(r'^user/', views.UserView.as_view()),
]
```

views.py文件内容

```python
from django.shortcuts import render,HttpResponse
from rest_framework.views import APIView

class UserView(APIView):

    def get(self,request,*args,**kwargs):
        print(request.__dict__)
        print(request.user)
        return HttpResponse("UserView GET")

    def post(self,request,*args,**kwargs):
        return HttpResponse("UserView POST")
```

启动项目，用浏览器向`http://127.0.0.1:8000/user/`发送get请求



可以知道请求发送成功。现在来看看源码流程，由于UserView继承APIView，查看APIView中的as_view方法

```python
class APIView(View):
    ...
    @classmethod
    def as_view(cls, **initkwargs):
        if isinstance(getattr(cls, 'queryset', None), models.query.QuerySet):
            def force_evaluation():
                raise RuntimeError(
                    'Do not evaluate the `.queryset` attribute directly, '
                    'as the result will be cached and reused between requests. '
                    'Use `.all()` or call `.get_queryset()` instead.'
                )
            cls.queryset._fetch_all = force_evaluation

        view = super(APIView, cls).as_view(**initkwargs)
        view.cls = cls
        view.initkwargs = initkwargs
        return csrf_exempt(view)
```

`通过super来执行APIView的父类Django的View中的as_view方法`。上一篇文章[源码解析Django CBV的本质](https://www.cnblogs.com/renpingsheng/p/9531649.html)中已经知道，View类的as_view方法会调用dispatch方法。

View类的as_view方法源码如下所示

```python
class View(object):
    ...
    @classonlymethod
    def as_view(cls, **initkwargs):
        ...
        def view(request, *args, **kwargs):
            self = cls(**initkwargs)
            if hasattr(self, 'get') and not hasattr(self, 'head'):
                self.head = self.get
            self.request = request
            self.args = args
            self.kwargs = kwargs
            return self.dispatch(request, *args, **kwargs)
        ...
```

`as_view方法中的self实际上指的是自定义的UserView这个类`，上面的代码会执行UserView类中dispatch方法。

由于UserView类中并没有定义dispatch方法，而UserView类继承自Django restframework的APIView类，所以会执行APIView类中的dispatch方法

```python
def dispatch(self, request, *args, **kwargs):
    self.args = args
    self.kwargs = kwargs
    request = self.initialize_request(request, *args, **kwargs)
    self.request = request
    self.headers = self.default_response_headers  # deprecate?

    try:
        self.initial(request, *args, **kwargs)
        if request.method.lower() in self.http_method_names:
            handler = getattr(self, request.method.lower(),
                              self.http_method_not_allowed)
        else:
            handler = self.http_method_not_allowed

        response = handler(request, *args, **kwargs)

    except Exception as exc:
        response = self.handle_exception(exc)

    self.response = self.finalize_response(request, response, *args, **kwargs)
    return self.response
```

可以看到，`先执行initialize_request方法处理浏览器发送的request请求`。

来看看initialize_request方法的源码

```python
def initialize_request(self, request, *args, **kwargs):
    """
    Returns the initial request object.
    """
    parser_context = self.get_parser_context(request)

    return Request(
        request,
        parsers=self.get_parsers(),
        authenticators=self.get_authenticators(),
        negotiator=self.get_content_negotiator(),
        parser_context=parser_context
    )
```

在initialize_request方法里，把浏览器发送的request和restframework的处理器，认证，选择器等对象列表作为参数实例化Request类中得到新的request对象并返回，其中跟认证相关的对象就是authenticators。

```python
def get_authenticators(self):
    """
    Instantiates and returns the list of authenticators that this view can use.
    """
    return [auth() for auth in self.authentication_classes]
```

`get_authenticators方法通过列表生成式得到一个列表，列表中包含认证类实例化后的对象`

在这里，`authentication_classes来自于api_settings的配置`

```
authentication_classes = api_settings.DEFAULT_AUTHENTICATION_CLASSES
```

通过查看api_settings的源码可以知道，可以在项目的settings.py文件中进行认证相关的配置

```python
api_settings = APISettings(None, DEFAULTS, IMPORT_STRINGS)

def reload_api_settings(*args, **kwargs):
    setting = kwargs['setting']
    if setting == 'REST_FRAMEWORK':
        api_settings.reload()
```

Django restframework通过initialize_request方法对原始的request进行一些封装后实例化得到新的request对象

然后执行initial方法来处理新得到的request对象，再来看看initial方法中又执行了哪些操作

```python
def initial(self, request, *args, **kwargs):
    self.format_kwarg = self.get_format_suffix(**kwargs)
    neg = self.perform_content_negotiation(request)
    request.accepted_renderer, request.accepted_media_type = neg

    version, scheme = self.determine_version(request, *args, **kwargs)
    request.version, request.versioning_scheme = version, scheme

    self.perform_authentication(request)
    self.check_permissions(request)
    self.check_throttles(request)
```

由上面的源码可以知道，在initial方法中，`执行perform_authentication来对request对象进行认证操作`

```python
def perform_authentication(self, request):
    request.user
```

`perform_authentication方法中调用执行request中的user方法`，`这里的request是封装了原始request,认证对象列表，处理器列表等之后的request对象`

```python
class Request(object):
    ...
    @property
    def user(self):
        """
        Returns the user associated with the current request, as authenticated
        by the authentication classes provided to the request.
        """
        if not hasattr(self, '_user'):
            with wrap_attributeerrors():
                self._authenticate()
        return self._user
```

从request中获取`_user`的值，如果获取到则执行`_authenticate方法`，否则返回`_user`

```
def _authenticate(self):
    """
    Attempt to authenticate the request using each authentication instance
    in turn.
    """
    for authenticator in self.authenticators:
        try:
            user_auth_tuple = authenticator.authenticate(self)
        except exceptions.APIException:
            self._not_authenticated()
            raise

        if user_auth_tuple is not None:
            self._authenticator = authenticator
            self.user, self.auth = user_auth_tuple
            return
```

在这里`self.authenticators`实际上是`get_authenticators`方法执行完成后返回的对象列表

```python
class Request(object):

    def __init__(self, request, parsers=None, authenticators=None,
                 negotiator=None, parser_context=None):
        assert isinstance(request, HttpRequest), (
            'The `request` argument must be an instance of '
            '`django.http.HttpRequest`, not `{}.{}`.'
            .format(request.__class__.__module__, request.__class__.__name__)
        )

        self._request = request
        self.parsers = parsers or ()
        self.authenticators = authenticators or ()
        ...
```

循环认证的对象列表,`执行每一个认证方法的类中的authenticate方法`，得到通过认证的用户及用户的口令的元组，并返回元组完成认证的流程

在`_authenticate`方法中使用了try/except方法来捕获authenticate方法可能出现的异常

如果出现异常,就调用`_not_authenticated`方法来设置返回元组中的用户及口令并终止程序继续运行

总结，Django restframework的认证流程如下图

![](/images/Django认证流程.jpg)

## Django restframework内置的认证类

在上面的项目例子中，在UsersView的get方法中，打印`authentication_classes`和`request._user`的值

```python
class UserView(APIView):
    # authentication_classes = [MyAuthentication,]

    def get(self,request,*args,**kwargs):
        print('authentication_classes:', self.authentication_classes)
        print(request._user)
        return HttpResponse("UserView GET")
```

打印结果为

```python
authentication_classes: [<class 'rest_framework.authentication.SessionAuthentication'>, <class 'rest_framework.authentication.BasicAuthentication'>]
AnonymousUser
```

由此可以知道,`authentication_classes`默认是Django restframework内置的认证类，而request._user为AnonymousUser,因为发送GET请求，用户没有进行登录认证，所以为匿名用户

在视图函数中导入这两个类,再查看这两个类的源码,可以知道

```python
class BasicAuthentication(BaseAuthentication):

    www_authenticate_realm = 'api' 

    def authenticate(self, request):

        ...

    def authenticate_credentials(self, userid, password):

        ...

class SessionAuthentication(BaseAuthentication):

    def authenticate(self, request):

        ...

    def enforce_csrf(self, request):

        ...

class TokenAuthentication(BaseAuthentication):
    ...
```

从上面的源码可以发现,这个文件中不仅定义了`SessionAuthentication`和`BasicAuthentication`这两个类,

相关的类还有`TokenAuthentication`,而且这三个认证相关的类都是继承自`BaseAuthentication`类

从上面的源码可以大概知道,这三个继承自`BaseAuthentication`的类是Django restframework内置的认证方式.

## 自定义认证功能

在上面我们知道,Request会调用认证相关的类及方法,`APIView`会设置认证相关的类及方法

所以如果想自定义认证功能,只需要重写`authenticate`方法及`authentication_classes`的对象列表即可

修改上面的例子的views.py文件

```python
from django.shortcuts import render, HttpResponse
from rest_framework.views import APIView
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions

TOKEN_LIST = [  # 定义token_list
    'aabbcc',
    'ddeeff',
]

class UserAuthView(BaseAuthentication):
    def authenticate(self, request):
        tk = request._request.GET.get("tk")  # request._request为原生的request

        if tk in TOKEN_LIST:
            return (tk, None)  # 返回一个元组
        raise exceptions.AuthenticationFailed("用户认证失败")

    def authenticate_header(self, request):
        # 如果不定义authenticate_header方法会抛出异常
        pass

class UserView(APIView):
    authentication_classes = [UserAuthView, ]

    def get(self, request, *args, **kwargs):
        print(request.user)

        return HttpResponse("UserView GET")
```

启动项目,在浏览器中输入`http://127.0.0.1:8000/users/?tk=aabbcc`,然后回车,在服务端后台会打印

```
aabbcc
```

把浏览器中的url换为`http://127.0.0.1:8000/users/?tk=ddeeff`,后台打印信息则变为

```
ddeeff
```

这样就实现REST framework的自定义认证功能

## Django restframework认证的扩展

### 基于Token进行用户认证

修改上面的项目，在urls.py文件中添加一条路由记录

```python
from django.conf.urls import url
from django.contrib import admin
from app01 import views

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^users/',views.UsersView.as_view()),
    url(r'^auth/',views.AuthView.as_view()),
]
```

修改视图函数

```python
from django.shortcuts import render,HttpResponse
from rest_framework.views import APIView
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions
from django.http import JsonResponse

def gen_token(username):
    """
    利用时间和用户名生成用户token
    :param username: 
    :return: 
    """
    import time
    import hashlib
    ctime=str(time.time())
    hash=hashlib.md5(username.encode("utf-8"))
    hash.update(ctime.encode("utf-8"))
    return hash.hexdigest()

class AuthView(APIView):
    def post(self, request, *args, **kwargs):
        """
        获取用户提交的用户名和密码，如果用户名和密码正确，则生成token，并返回给用户
        :param request:
        :param args:
        :param kwargs:
        :return:
        """
        res = {'code': 1000, 'msg': None}
        user = request.data.get("user")
        pwd = request.data.get("pwd")

        from app01 import models
        user_obj = models.UserInfo.objects.filter(user=user, pwd=pwd).first()

        if user_obj:
            token = gen_token(user) # 生成用户口令

            # 如果数据库中存在口令则更新,如果数据库中不存在口令则创建用户口令
            models.Token.objects.update_or_create(user=user_obj, defaults={'token': token})
            print("user_token:", token)
            res['code'] = 1001
            res['token'] = token
        else:
            res['msg'] = "用户名或密码错误"

        return JsonResponse(res)

class UserAuthView(BaseAuthentication):
    def authenticate(self,request):
        tk=request.query_params.GET.get("tk")   # 获取请求头中的用户token

        from app01 import models

        token_obj=models.Token.objects.filter(token=tk).first()

        if token_obj:   # 用户数据库中已经存在用户口令返回认证元组
            return (token_obj.user,token_obj)

        raise exceptions.AuthenticationFailed("认证失败")

    def authenticate_header(self,request):
        pass

class UsersView(APIView):
    authentication_classes = [UserAuthView,]

    def get(self,request,*args,**kwargs):

        return HttpResponse(".....")
```

创建用户数据库的类

```python
from django.db import models

class UserInfo(models.Model):
    user=models.CharField(max_length=32)
    pwd=models.CharField(max_length=64)
    email=models.CharField(max_length=64)

class Token(models.Model):
    user=models.OneToOneField(UserInfo)
    token=models.CharField(max_length=64)
```

创建数据库,并添加两条用户记录

再创建一个test_client.py文件,来发送post请求

```python
import requests

response=requests.post(
    url="http://127.0.0.1:8000/auth/",
    data={'user':'user1','pwd':'user123'},
)

print("response_text:",response.text)
```

启动Django项目,运行test_client.py文件,则项目的响应信息为

```python
response_text: {"code": 1001, "msg": null, "token": "eccd2d256f44cb25b58ba602fe7eb42d"}
```

由此,就完成了自定义的基于token的用户认证

如果想在项目中使用自定义的认证方式时,可以在`authentication_classes`继承刚才的认证的类即可

```python
authentication_classes = [UserAuthView,APIViiew]
```







