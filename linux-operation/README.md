###
rename.sh 这个脚本是需要传入一个参数的，如传入sign，将来会修改主机名为：sign-“ip”这样的形式



    server {
        listen       8888;
        server_name  wzcccc.test.com;
        location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forward-For $remote_addr;
        proxy_pass  https://wpr.zqsign.com/;
        }
    }
