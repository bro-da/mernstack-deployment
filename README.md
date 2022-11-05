# mernstack-deployment
A simple step by step process for hosting mernstack web app on any server with out hassle


- [mernstack-deployment](#mernstack-deployment)
  - [introduction](#introduction)
  - [step 1 - setup a server with custom user](#step-1---setup-a-server-with-custom-user)
  - [step 2 - Installing Node.js](#step-2---installing-nodejs)
  - [Step 3 — Creating a Node.js Application](#step-3--creating-a-nodejs-application)
  - [step 4 -  Installing PM2 and running pm2](#step-4----installing-pm2-and-running-pm2)
  - [step 5 - Setting Up Nginx as a Reverse Proxy Server](#step-5---setting-up-nginx-as-a-reverse-proxy-server)
  - [step 5 -hosting our app](#step-5--hosting-our-app)
  - [References](#references)


## introduction
I made this repo because some of my friends had difficulties deploying mernstack  web apps on aws because They had little to no experiance working on cli based system .Most get through (even me) by refering multiple pages and using various hacks but after at the end the deployment They get so overwhemed They forget the entire process so i am creating this repo so that those with difficulty can get the all the commands for deployment right here and as a source for further reference 


## step 1 - setup a server with custom user
Before you begin, you should have a non-root user account with sudo privileges set up on your system. 
1. create a server (ec2 instance works best and is pretty painless to create) 
    * make sure to open the http and https and ssh ports when creating the instance otherwise you have to go tinker on the security to get them to open
    * login to the ec2 instance through the .pem file you received during the instance creation process
2. after login when we look to the prompt we could see we are logged in as ubuntu its always better to create a new user and unlock the ssh login through password     so we could login anywhere and login even if we lose our pem keys
3. steps to create a user in ubuntu
   
    ```shell
    sudo adduser USER
    ```
 give the user any name you want


        ```shell
        sudo usermod -aG sudo USER
        ```

this command helps to give the user USER sudo privilege 

1. setup  ufw: This step is important not beacause its important (aws already has a firewall built-in ) but because i see many (even me ) people activate the wfw without allowing ssh and http port through i guess if we activate ufw without fully completing getting ssh connection to the instance requires extra tinkering 
 refer this if it happened to you [ssh not connecting](https://stackoverflow.com/questions/41929267/locked-myself-out-of-ssh-with-ufw-in-ec2-aws).

 ```shell
 sudo ufw allow OpenSSH
 sudo ufw enable 
 ufw status # continue only if you see openssh on the list
 ```

2 .steps to enable ssh password authentication on
    ```shell
    sudo nano /etc/ssh/sshd_config # find "PasswordAuthentication" enabling it  yes
    sudo service sshd restart
    ```
    only logout after doing this step and rechecking ufw allow list.
    logout and reconnect through ssh using new user and password
    
    ```
    ssh USER@IP-ADDRESS
    ```


## step 2 - Installing Node.js
The digital ocean has multiple ways to install nodejs through the apt package manager,using nodejs installation script and through node version manager(nvm) i suggest using nodejs installation script beacause the one in apt may sometime be outdated and nvm needs and extra program to install the one from script can be installed we hope we can trust digital ocean
you can through the script if you're finnicky sometimes it doesnt matter how you install but you install the correct nodejs version in which you developed in

```shell
cd ~
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
nano nodesource_setup.sh
sudo bash nodesource_setup.sh
node -v

```

## Step 3 — Creating a Node.js Application

the site digitial ocean advises creating a simple nodejs application check if its working .This could be usefull if you need to check the pm2 and nginx is working or no

```shell
cat << 'EOF' >> hell0.js
const http = require('http');

const hostname = 'localhost';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
EOF

node hello.js
curl http://localhost:3000
```
> Hello World!

## step 4 -  Installing PM2 and running pm2


1. let’s install PM2, a process manager for Node.js applications. PM2 makes it possible to daemonize applications so that they will run in the background as a service.

```shell
sudo npm install pm2@latest -g

pm2 start hello.js # runn the hellojs program in the background see we dont want to run the app with node
```

2. setup pm2 to run at start up and in background

```shell
pm2 startup systemd
```
this next command will allow pm2 superuser privileges in order to  to start on boo
```
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u sammy --hp /home/USER

```
3. Start the pm2 service with systemctl

```shell
sudo systemctl start pm2-USER
```

## step 5 - Setting Up Nginx as a Reverse Proxy Server

```shell
sudo nano /etc/nginx/sites-available/APPNAME
```

2. add a nginx file by copying the below into the correct place

```
server {

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

}
```
3. check if the configuration file is correct and restart
```shell
sudo nginx -t
sudo systemctl restart nginx
```

## step 5 -hosting our app

Now that both pm2 and nginx is working we can git clone our nodejs application to the server and set it up
1. git clone or scp your source code
```
cd 
git clone https://your.nodeapp.com
```

2. remove hello application if its still running

```
pm2 list
pm2 stop hello.js
pm2 start YOURAPP/bin/www
pm2 list
```
3. restart pm2 and nginx the deployment is finished
```shell
sudo systemctl restart pm2-USER
sudo systemctl restart nginx
````

## References
1. i created this repo so people doesnt have to go to refer many sites and get confused most of the code is borrowed from [digitalocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-22-04) even the hello.js program
2 initial server setup is also [digital ocean](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04) but i hope i made it easier