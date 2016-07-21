#!/bin/bash
source /usr/local/src/template.renderer.sh

function initRundeck()
{
    # define default configuration values
    SERVER_URL=${SERVER_URL:-}
    SERVER_HOSTNAME=$(echo ${SERVER_URL} | awk -F/ "{print $3}" | awk -F: "{print $1}")
    SERVER_PROTO=$(echo ${SERVER_URL} | awk -F/ "{print $1}" | awk -F: "{print $1}")
    SERVER_PORT=$(echo ${SERVER_URL} | awk -F/ "{print $3}" | awk -F: "{print $2}")
    if [ -z ${SERVER_PORT} ]; then
      # No port in SERVER_URL so assume 443 for HTTPS or 80 otherwise
      if [ ${SERVER_PROTO} == "https" ]; then
         SERVER_PORT=443
      else
         SERVER_PORT=80
      fi
    fi
    DATABASE_HOSTNAME=${DATABASE_HOSTNAME:-"db"}
    DATABASE_NAME=${DATABASE_NAME:-"rundeck"}
    DATABASE_URL=${DATABASE_URL:-"jdbc:mysql://${DATABASE_HOSTNAME}/${DATABASE_NAME}?autoReconnect=true"}
    DB_ENV_DATABASE_USER=${DB_ENV_DATABASE_USER:-"rundeck"}
    DB_ENV_DATABASE_PASSWORD=${DB_ENV_DATABASE_USER:-"rundeck"}
	DATABASE_USER=${DATABSE_USER:-${DB_ENV_DATABASE_USER}}
	DATABASE_PASSWORD=${DATABASE_PASSWORD:-${DB_ENV_DATABASE_PASSWORD}}
    RUNDECK_PASSWORD=${RUNDECK_PASSWORD:-$(pwgen -s 20 1)}
    RUNDECK_STORAGE_PROVIDER=${RUNDECK_STORAGE_PROVIDER:-"file"}
    RUNDECK_PROJECT_STORAGE_TYPE=${RUNDECK_PROJECT_STORAGE_TYPE:-"file"}
    ADMIN_USER=${ADMIN_USER:-'admin'}
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(pwgen -s 20 1)}
    RUNDECK_SSH_USER=${RUNDECK_SSH_USER-'rundeck'}

	if [ ! -f /var/lib/rundeck/.ssh/id_rsa ]; then
		echo "=>Generating rundeck key"
		sudo -u rundeck ssh-keygen -t rsa -b 4096 -f /var/lib/rundeck/.ssh/id_rsa -N ""
	fi

	echo "=> Rendering configuration..."
	render /usr/local/src/rundeck/templates/rundeck-config.properties.template -- > /etc/rundeck/rundeck-config.properties
	render /usr/local/src/rundeck/templates/framework.properties.template -- > /etc/rundeck/framework.properties

	if ls /usr/local/src/rundeck/plugins/*.[jar|zip|groovy] 1> /dev/null 2>&1; then
		echo "=>Installing plugins from /usr/local/src/rundeck/plugins"
		mv /usr/local/src/rundeck/plugins/*.[jar|zip|groovy] /var/lib/rundeck/libext 2>/dev/null
	fi
}
