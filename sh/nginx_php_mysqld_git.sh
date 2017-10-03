脚本需求组合：
lnmp(linux + Nginx + MySQL + PHP)
lamp(linux + Apache + MySQL + PHP)
lnmpa(Linux + Nginx + MySQL + PHP + Apache):nginx处理静态，Apache(mod_php)处理动态PHP
lnmt(Linux + Nginx + MySQL + Tomcat):Nginx处理静态，Tomcat(JDK)处理Java
lnmh(linux + Nginx + MySQL + HHVM)

lnmp(linux + Nginx + MySQL + PHP) 配置

1.配置防火墙，开启80端口，3306端口
特别提示：很多网友把这两条规则添加到防火墙配置的最后一行，导致防火墙启动失败，正确的应该是添加到默认的22端口这条规则的下面

vim /etc/sysconfig/iptables

-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT

-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT              #允许80端口通过防火墙
-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT            #允许3306端口通过防火墙

/etc/init.d/iptables restart   #最后重启防火墙使配置生效


2.关闭selinux
vi /etc/selinux/config
#SELINUX=enforcing #注释掉
#SELINUXTYPE=targeted #注释掉
SELINUX=disabled #增加
:wq 保存，关闭
shutdown -r now #重启系统

3.系统约定
软件源代码包存放位置：/usr/local/src
源码包编译安装位置：/usr/local/软件名字


4.软件包准备

ngix包
wget http://mirrors.linuxeye.com/oneinstack/src/nginx-1.10.0.tar.gz    
wget http://nginx.org/download/nginx-1.9.9.tar.gz  

pcre包（支持nginx伪静态）   

wget http://mirrors.linuxeye.com/oneinstack/src/pcre-8.38.tar.gz

php包

wget http://cn.php.net/distributions/php-5.4.5.tar.gz
wget http://mirrors.linuxeye.com/oneinstack/src/php-5.4.45.tar.gz

cmake（MySQL编译工具）

wget http://www.cmake.org/files/v2.8/cmake-2.8.8.tar.gz

libmcrypt包（PHPlibmcrypt模块）

wget http://mirrors.linuxeye.com/oneinstack/src/libmcrypt-2.5.8.tar.gz

5.安装编译工具及库文件（使用CentOS yum命令安装）
yum install gcc gcc-cpp gcc-c++ zlib-devel

6.安装mysql编译等（略）


7.安装pcre
mkdir /usr/local/pcre #创建安装目录
tar -zxvf pcre-8.38.tar.gz
cd pcre-8.38
./configure --prefix=/usr/local/pcre #配置
make && make install

8.安装nginx
groupadd www    #添加www组
useradd -g www www -s /bin/false   #创建nginx运行账户www并加入到www组，不允许www用户直接登录系统
tar -zxvf nginx-1.10.0.tar.gz
cd nginx-1.10.0
./configure --prefix=/usr/local/nginx --without-http_memcached_module --user=www --group=www --http-fastcgi-temp-path=/tmp/nginx/fastcgi_temp  --http-proxy-temp-path=/tmp/nginx/nginx_proxy_temp  --http-client-body-temp-path=/tmp/nginx/client_body_temp --without-http_autoindex_module --without-http_scgi_module --without-http_uwsgi_module  --with-http_gzip_static_module --with-http_stub_status_module --with-openssl=/usr/ --with-pcre=/root/pcre-8.38
注意:--with-pcre=/root/pcre-8.38指向的是源码包解压的路径，而不是安装的路径，否则会报错
make && make install
/usr/local/nginx/sbin/nginx     #启动nginx

设置nginx开启启动
vi /etc/rc.d/init.d/nginx #编辑启动文件添加下面内容
=======================================================
#!/bin/bash
# nginx Startup script for the Nginx HTTP Server
# it is v.0.0.2 version.
# chkconfig: - 85 15
# description: Nginx is a high-performance web and proxy server.
# It has a lot of features, but it's not for everyone.
# processname: nginx
# pidfile: /var/run/nginx.pid
# config: /usr/local/nginx/conf/nginx.conf
nginxd=/usr/local/nginx/sbin/nginx
nginx_config=/usr/local/nginx/conf/nginx.conf
nginx_pid=/usr/local/nginx/logs/nginx.pid
RETVAL=0
prog="nginx"
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
[ -x $nginxd ] || exit 0
# Start nginx daemons functions.
start() {
if [ -e $nginx_pid ];then
echo "nginx already running...."
exit 1
fi
echo -n $"Starting $prog: "
daemon $nginxd -c ${nginx_config}
RETVAL=$?
echo
[ $RETVAL = 0 ] && touch /var/lock/subsys/nginx
return $RETVAL
}
# Stop nginx daemons functions.
stop() {
echo -n $"Stopping $prog: "
killproc $nginxd
RETVAL=$?
echo
[ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /usr/local/nginx/logs/nginx.pid
}
reload() {
echo -n $"Reloading $prog: "
#kill -HUP `cat ${nginx_pid}`
killproc $nginxd -HUP
RETVAL=$?
echo
}
# See how we were called.
case "$1" in
start)
start
;;
stop)
stop
;;
reload)
reload
;;
restart)
stop
start
;;
status)
status $prog
RETVAL=$?
;;
*)
echo $"Usage: $prog {start|stop|restart|reload|status|help}"
exit 1
esac
exit $RETVAL
=======================================================
:wq! #保存退出
chmod 775 /etc/rc.d/init.d/nginx #赋予文件执行权限
chkconfig nginx on #设置开机启动
/etc/rc.d/init.d/nginx restart #重启
service nginx restart
=======================================================

9.安装libmcrypt
tar -zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure #配置
make #编译
make install #安装

10.安装PHP
tar -zxvf php-5.4.45.tar.gz
cd php-5.4.45
mkdir -p /usr/local/php
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql --with-gd --with-iconv --with-zlib --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-mcrypt --with-curl #配置

make #编译
make install #安装
cp php.ini-production /usr/local/php/etc/php.ini #复制php配置文件到安装目录

rm -rf /etc/php.ini #删除系统自带配置文件
ln -s /usr/local/php/etc/php.ini /etc/php.ini #添加软链接


cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf #拷贝模板文件为php-fpm配置文件


vi /usr/local/php/etc/php-fpm.conf #编辑
user = www #设置php-fpm运行账号为www
group = www #设置php-fpm运行组为www
pid = run/php-fpm.pid #取消前面的分号
设置 php-fpm开机启动
cp /root/php-5.4.45/sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm #拷贝php-fpm到启动目录
chmod +x /etc/rc.d/init.d/php-fpm #添加执行权限
chkconfig php-fpm on #设置开机启动
vi /usr/local/php/etc/php.ini #编辑配置文件
找到：disable_functions =

disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,getservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd, posix_getegid,posix_geteuid,posix_getgid, posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid, posix_getppid,posix_getpwnam,posix_getpwuid, posix_getrlimit, posix_getsid,posix_getuid,posix_isatty, posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid, posix_setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname

#列出PHP可以禁用的函数，如果某些程序需要用到这个函数，可以删除，取消禁用。
找到：;date.timezone =
修改为：date.timezone = PRC #设置时区
找到：expose_php = On
修改为：expose_php = OFF #禁止显示php版本的信息
找到：short_open_tag = Off
修改为：short_open_tag = ON #支持php短标签

11.配置nginx支持php

vi /usr/local/nginx/conf/nginx.conf #编辑配置文件,需做如下修改
user www www; #首行user去掉注释,修改Nginx运行组为www www；必须与/usr/local/php5/etc/php-fpm.conf中的user,group配置相同，否则php运行出错
index index.php index.html index.htm; #添加index.php
# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
#
location ~ \.php$ {
root html;
fastcgi_pass 127.0.0.1:9000;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;
}
#取消FastCGI server部分location的注释,并要注意fastcgi_param行的参数,改为$document_root$fastcgi_script_name,或者使用绝对路径
/etc/init.d/nginx restart #重启nginx


12.测试篇

cd /usr/local/nginx/html/ #进入nginx默认网站根目录
rm -rf /usr/local/nginx/html/* #删除默认测试页
vi index.php #编辑
<?php
phpinfo();
?>
:wq! #保存退出
chown www.www /usr/local/nginx/html/ -R #设置目录所有者
chmod 700 /usr/local/nginx/html/ -R #设置目录权限
shutdown -r now #重启系统
在浏览器中打开服务器IP地址，会看到下面的界面，配置成功


=========================================================++++++++++++++++++++++=============================================
服务器相关操作命令
service nginx restart #重启nginx
service mysqld restart #重启mysql
/usr/local/php/sbin/php-fpm #启动php-fpm
/etc/rc.d/init.d/php-fpm restart #重启php-fpm
/etc/rc.d/init.d/php-fpm stop #停止php-fpm
/etc/rc.d/init.d/php-fpm start #启动php-fpm

备注：
nginx默认站点目录是：/usr/local/nginx/html/
权限设置：chown www:www /usr/local/nginx/html/ -R
MySQL数据库目录是：/data/mysql
权限设置：chown mysql.mysql -R /data/mysql

===========================================================+++++++++++++++++++++++++===========================================
 

