###


##### rename_v0.1.sh 
* 这个脚本是需要传入一个参数的，如传入"sign"字符，也可以在脚本中修改变量meachine的值，将$1替换为想要的字符
```bash
./renmae_v0.1.sh zqsign
```

##### tomcatd.sh 
* 此脚本是一键启动tomcat服务的，运行时需要修改JAVA_HOME等环境变量，不过如果系统已经设置好了，就没有必要在此脚本中配置了。
```bash
./tomcatd.sh {start/stop/restart/ status}
```

##### jar_scripts.sh 
* 此脚本是一键启动jar 包，只需要此脚本与jar包都存放到同一个目录下即可。推荐存放到以应用名称命名的目录下方
```bash
./jar_scripts.sh {start/stop/restart/ status}
```

##### jar_scripts.sh 
* 直接运行此脚本即可，安装完成后启动ftpd，此服务的用户名是：ftpd，密码是：zhxy2015col
```bash
./install-ftp.sh
```

