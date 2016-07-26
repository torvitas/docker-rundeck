#!/bin/bash
source /usr/local/src/rundeck/bin/template.renderer.sh

function initRundeck()
{
    # define default configuration values
    SERVER_URL=${SERVER_URL:-}
    SERVER_HOSTNAME=$(echo ${SERVER_URL} | awk -F/ '{print $3}' | awk -F: '{print $1}')
    SERVER_PROTO=$(echo ${SERVER_URL} | awk -F/ '{print $1}' | awk -F: '{print $1}')
    SERVER_PORT=$(echo ${SERVER_URL} | awk -F/ '{print $3}' | awk -F: '{print $2}')
    if [ -z ${SERVER_PORT} ]; then
      # No port in SERVER_URL so assume 443 for HTTPS or 80 otherwise
      if [ "${SERVER_PROTO}" == "https" ]; then
         SERVER_PORT=443
      else
         SERVER_PORT=80
      fi
    fi
    function renderDatabaseUrl()
    {
        echo "jdbc:mysql://${DATABASE_HOSTNAME}/${DATABASE_NAME}?autoReconnect=true"
    }

    DATABASE_HOSTNAME=${DATABASE_HOSTNAME:-db}
    DB_ENV_MYSQL_USER=${DB_ENV_MYSQL_USER:-rundeck}
    DB_ENV_MYSQL_PASSWORD=${DB_ENV_MYSQL_PASSWORD:-rundeck}
    DB_ENV_MYSQL_DATABASE=${DB_ENV_MYSQL_DATABASE:-rundeck}
    DATABASE_NAME=${DATABASE_NAME:-${DB_ENV_MYSQL_DATABASE}}
	DATABASE_USER=${DATABSE_USER:-${DB_ENV_MYSQL_USER}}
	DATABASE_PASSWORD=${DATABASE_PASSWORD:-${DB_ENV_MYSQL_PASSWORD}}
    DATABASE_URL=${DATABASE_URL:-$(renderDatabaseUrl)}
    initUsers
    RUNDECK_STORAGE_PROVIDER=${RUNDECK_STORAGE_PROVIDER:-file}
    RUNDECK_PROJECT_STORAGE_TYPE=${RUNDECK_PROJECT_STORAGE_TYPE:-file}
    ADMIN_USER=${ADMIN_USER:-admin}
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(pwgen -s 20 1)}
    RUNDECK_SSH_USER=${RUNDECK_SSH_USER-rundeck}

	if [ ! -f /var/lib/rundeck/.ssh/id_rsa ]; then
		echo "=>Generating rundeck key"
		sudo -u rundeck ssh-keygen -t rsa -b 4096 -f /var/lib/rundeck/.ssh/id_rsa -N ""
	fi

	echo "=> Rendering configuration..."
	render /usr/local/src/rundeck/templates/rundeck-config.properties.template -- > /etc/rundeck/rundeck-config.properties
	render /usr/local/src/rundeck/templates/framework.properties.template -- > /etc/rundeck/framework.properties

	if ls /usr/local/src/rundeck/plugins/*.{jar,zip,groovy} 1> /dev/null 2>&1; then
		echo "=>Installing plugins from /usr/local/src/rundeck/plugins"
		mv /usr/local/src/rundeck/plugins/*.{jar,zip,groovy} /var/lib/rundeck/libext 2>/dev/null
	fi

	echo "=> Setting permissions..."
    mkdir -p /var/log/rundeck
	touch /var/log/rundeck/rundeck.log
	chown -R rundeck.rundeck /var/log/rundeck

	echo "=> Settings:"
	function printSettings()
	{
	    echo "===================================="
	    echo "- Server Hostname: ${SERVER_HOSTNAME}"
	    echo "- Server Protocol: ${SERVER_PROTO}"
	    echo "- Server Port: ${SERVER_PORT}"
	    echo "- Server Url: ${SERVER_URL}"
	    echo "- Database Hostname: ${DATABASE_HOSTNAME}"
	    echo "- Database Name: ${DATABASE_NAME}"
	    echo "- Database URL: ${DATABASE_URL}"
	    echo "- Database User: ${DATABASE_USER}"
	    echo "- Database Password: ${DATABASE_PASSWORD}"
	    echo "- Rundeck User: ${RUNDECK_USER}"
	    echo "- Rundeck Password: ${RUNDECK_USER_PASSWORD}"
	    echo "- Rundeck Storage Provider: ${RUNDECK_STORAGE_PROVIDER}"
	    echo "- Rundeck Project Storage Type: ${RUNDECK_PROJECT_STORAGE_TYPE}"
	    echo "- CLI User: ${ADMIN_USER}"
	    echo "- CLI Password: ${ADMIN_PASSWORD}"
	    echo "===================================="
    }
    printSettings > /etc/rundeck/settings.txt
    printSettings
}

function buildVariable()
{
    echo "RUNDECK_${1}_${2}"
}

buildPasswordHash()
{
    user=${1}
    password=${2}
    md5=${3}
    if [ ! ${md5} ]; then
        md5=$(java -cp /var/lib/rundeck/bootstrap/jetty-all-7.6.0.v20120127.jar org.eclipse.jetty.util.security.Password ${user} ${password} 2>&1 | sed -n 3p)
    fi
    echo ${md5}
}

function initUsers()
{
	echo "=> Rendering user configuration..."
    RUNDECK_USER=${RUNDECK_USER:-rundeck}
    RUNDECK_USER_PASSWORD=${RUNDECK_USER_PASSWORD:-$(pwgen -s 20 1)}
    RUNDECK_USER_MD5=$(buildPasswordHash ${RUNDECK_USER} ${RUNDECK_PASSWORD} ${RUNDECK_USER_MD5})
	render /usr/local/src/rundeck/templates/realm.properties.template -- > /etc/rundeck/realm.properties
    i=0
    user=$(buildVariable "USER" ${i})
    password=$(buildVariable "USER_PASSWORD" ${i})
    md5=$(buildVariable "USER_MD5" ${i})
    passwordHash=$(buildPasswordHash ${!user} ${!password} ${!md5})
    permission=$(buildVariable "USER_PERMISSION" ${i})
    while [ ${!user} ]; do
        echo ${!user}: ${passwordHash},${!permission:=user} | tee -a /etc/rundeck/realm.properties
        let i=i+1
        user=$(buildVariable "USER" ${i})
        password=$(buildVariable "USER_PASSWORD" ${i})
        md5=$(buildVariable "USER_MD5" ${i})
        passwordHash=$(buildPasswordHash ${!user} ${!password} ${!md5})
        permission=$(buildVariable "USER_PERMISSION" ${i})
    done
}

