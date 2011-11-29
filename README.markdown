A demo for ytoolkit
===================

What is it?
-----------

This project is just a demo of usage of [ytoolkit] project, see the project for details.

It includes:

* [Twitter] authentication and data retrieving (OAuth 1.0)
* [Douban] authentication and data retrieving (OAuth 1.0)
* [QQ weibo] authentication and data retrieving (OAuth 1.0)
* [Flickr] not finished (OAuth 1.0)
* [Sina Weibo] authentication and data retrieving (OAuth 2.0 only, OAuth 1.0 not finished, cannot find the api doc for entering the last PIN code)
* [Facebook] authentication and data retieving (OAuth 2.0)
* [live] not finished.

* [Base64 profiling] my implementation benchmark comparision to GNUCoreUtils base64, NSData+Base64 and libb64.

[Twitter]: http://www.twitter.com
[Douban]: http://www.douban.com
[QQ weibo]: http://t.qq.com
[Flickr]: http://www.flickr.com
[Sina Weibo]: http://www.weibo.com
[Facebook]: http://www.facebook.com
[live]: http://www.live.com


[ytoolkit]: https://github.com/sprhawk/ytoolkit

How to build it ?
-----------------
1. Clone it to your local.
2. Clone the submodule using

```
    $ git submodule init
    $ git submodule update
```

   submodule includes: [ytoolkit], [SBJson], and [ASIHTTPRequest]
3. Open the project, if you are using a iOS is 5.0 earlier, you MUST change SBJson-ios lib's ARC setting to '**NO**'

4. Register and apply your own API key/secret, in the corresponding ClientCredentials.m

5. Build and run the project.


[ASIHTTPRequest]: https://github.com/pokeb/asi-http-request.git
[SBJson]: http://stig.github.com/json-framework/

License
-------

ytoolkitdemo is distributed under FreeBSD license. However, the ytoolkit is under LGPL v3 (except ASIHTTPRequest additions are under FreeBSD license)



