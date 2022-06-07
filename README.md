# wisebits-docker

1. Installation

Run commands
```
git clone git@github.com:bubble-double/wisebits-docker.git
sudo chmod +x ./wisebits-docker/bin/init.sh
./wisebits-docker/bin/init.sh
```

Check if everything is OK.
```angular2html
cd ./wisebits-docker && docker-compose ps
```

Running Tests
```angular2html
cd ./wisebits-docker && docker-compose exec php-fpm /bin/sh
cd wisebits && php artisan test
```

The command ```init.sh```: 
  - will create configuration files, 
  - will clone the repository 
    ```https://github.com/bubble-double/wisebits-docker```  
    into source code directory, 
  - will pull docker images, 
  - will run docker containers, 
  - will install composer dependencies.

NOTE:
Running the command ```init.sh``` is safe!

See https://github.com/bubble-double/wisebits
