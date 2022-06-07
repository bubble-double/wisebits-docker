#!/usr/bin/env bash

COLOR_GREEN='\033[0;32m'
COLOR_DEFAULT='\033[0m'

# Clone git repository
runClone() {
    module=$1
    dir=$2
    link=$3

    printf "${COLOR_GREEN}Clone a repository${COLOR_DEFAULT}: $module\nRepo url: $link\n"
    git clone ${link} ${dir}
    printf "${COLOR_GREEN}Successfully cloned${COLOR_DEFAULT}: %s \n\n" ${module}
}

SOURCE="${BASH_SOURCE[0]}"
ROOT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..
SOURCE_DIR="${ROOT_DIR}/source"

declare -A GIT_LINKS=(
    ['wisebits']='https://github.com/bubble-double/wisebits.git'
    # Add other repositories if needed
)

printf "${COLOR_GREEN}Start cloning repositories${COLOR_DEFAULT}\n"

# Clone git repositories
countRepositories=0
for repository in "${!GIT_LINKS[@]}"
do
    link=${GIT_LINKS[$repository]}
    directory=${SOURCE_DIR}/${repository}

    # Clone if directory is not exists
    if [ ! -d ${directory} ]; then
        runClone ${repository} ${directory} ${link}

        let countRepositories++
    fi
done

if [ ${countRepositories} -eq 0 ]; then
    printf "${COLOR_GREEN}There are not new repositories${COLOR_DEFAULT}\n"
fi

# docker-compose.override.yml
if [ ! -f ${ROOT_DIR}/docker-compose.override.yml ]; then
    printf "\n${COLOR_GREEN}Creating docker-compose.override.yml${COLOR_DEFAULT}\n"
    cp ${ROOT_DIR}/docker-compose.override.yml.dist ${ROOT_DIR}/docker-compose.override.yml
fi

# .env
if [ ! -f ${ROOT_DIR}/.env ]; then
    printf "\n${COLOR_GREEN}Creating .env${COLOR_DEFAULT}\n"
    cp ${ROOT_DIR}/.env.dist ${ROOT_DIR}/.env
fi

# php.ini
PATH_TO_PHP_INI=${ROOT_DIR}/images/php-fpm/conf/php.ini
if [ ! -f ${PATH_TO_PHP_INI} ]; then
    printf "\n${COLOR_GREEN}Creating ${PATH_TO_PHP_INI}${COLOR_DEFAULT}\n"
    cp ${PATH_TO_PHP_INI}.dist ${PATH_TO_PHP_INI}
fi

# opcache.ini
PATH_TO_OPCACHE_INI=${ROOT_DIR}/images/php-fpm/conf/opcache.ini
if [ ! -f ${PATH_TO_OPCACHE_INI} ]; then
    printf "\n${COLOR_GREEN}Creating ${PATH_TO_OPCACHE_INI}${COLOR_DEFAULT}\n"
    cp ${PATH_TO_OPCACHE_INI}.dist ${PATH_TO_OPCACHE_INI}
fi

# xdebug.ini
PATH_TO_XDEBUG_INI=${ROOT_DIR}/images/php-fpm/xdebug/xdebug.ini
if [ ! -f ${PATH_TO_XDEBUG_INI} ]; then
    printf "\n${COLOR_GREEN}Creating ${PATH_TO_XDEBUG_INI}${COLOR_DEFAULT}\n"
    cp ${PATH_TO_XDEBUG_INI}.dist ${PATH_TO_XDEBUG_INI}
fi

# Pull containers
printf "\n${COLOR_GREEN}Pull docker containers${COLOR_DEFAULT}\n"
cd ${ROOT_DIR} && docker-compose pull

# Build and run containers
printf "\n${COLOR_GREEN}Start docker containers${COLOR_DEFAULT}\n"
cd ${ROOT_DIR} && docker-compose up -d --build

printf "\n${COLOR_GREEN}Start composer install${COLOR_DEFAULT}\n"
docker-compose exec php-fpm /bin/sh -c "cd /var/www/wisebits && composer install --prefer-source"

# wisebits/.env
PATH_TO_PROJECT_ENV_FILE=${ROOT_DIR}/source/wisebits/.env
if [ ! -f ${PATH_TO_PROJECT_ENV_FILE} ]; then
    printf "\n${COLOR_GREEN}Creating ${PATH_TO_PROJECT_ENV_FILE}${COLOR_DEFAULT}\n"
    cp ${PATH_TO_PROJECT_ENV_FILE}.example ${PATH_TO_PROJECT_ENV_FILE}
fi

# Run composer dump
printf "\n${COLOR_GREEN}Start composer dump-autoload${COLOR_DEFAULT}\n"
docker-compose exec php-fpm /bin/sh -c "cd /var/www/wisebits && composer dump-autoload"
