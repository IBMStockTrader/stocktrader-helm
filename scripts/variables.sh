# Variables used by configuration shell scripts

#######################
#  GENERAL VARIABLES  #
#######################

# Kubernetes namespace where the stocktrader application is or will be installed.
STOCKTRADER_NAMESPACE="stocktrader"

###########################
#  DB2-RELATED VARIABLES  #
###########################

# DB2 Helm chart name
DB2_CHART="ibm-db2oltp-dev"

# DB2 Helm chart version
DB2_CHART_VERSION="3.1.0"

# DB2 Helm release name.  Set this if the DB2 chart is installed multiple times to indicate which one to use.  Otherwise leave it blank.
DB2_RELEASE_NAME=""

# DB2 user
DB2_USER="db2inst1"

# DB2 password.  The setup script attempts to find this value so set this only if the script is unable to do so.
DB2_PASSWORD=""

# DB2 service name.  The setup script attempts to find this value so set this only if the script is unable to do so.
DB2_SERVICE_NAME=""

# DB2 port number
DB2_PORT=50000

# DB2 Kubernetes namespace.  The setup script attempts to find this value so set this only if the script is unable to do so.
DB2_NAMESPACE=""

# Database name that you created for the stocktrader application
STOCKTRADER_DB="trader"


##########################
#  MQ-RELATED VARIABLES  #
##########################

# MQ Helm chart name
MQ_CHART="ibm-mqadvanced-server-dev"

# MQ Helm release name.  Set this if the MQ chart is installed multiple times to indicate which one to use.  Otherwise leave it blank.
MQ_RELEASE_NAME=""

# MQ app password.  The setup script attempts to find this value so set this only if the script is unable to do so.
MQ_APP_PASSWORD=""

# MQ queue manager name.  The setup script attempts to find this value so set this only if the script is unable to do so.
MQ_QMGR=""

# MQ service name.  The setup script attempts to find this value so set this only if the script is unable to do so.
MQ_SERVICE_NAME=""

# MQ port number
MQ_PORT=1414

# MQ Kubernetes namespace.  The setup script attempts to find this value so set this only if the script is unable to do so.
MQ_NAMESPACE=""


###########################
#  ODM-RELATED VARIABLES  #
###########################

# ODM Helm chart name
ODM_CHART="ibm-odm-dev"

# ODM Helm chart version
ODM_CHART_VERSION="1.1.0"

# ODM Helm release name.  Set this if the ODM chart is installed multiple times to indicate which one to use.  Otherwise leave it blank.
ODM_RELEASE_NAME=""

# ODM admin user
ODM_USER="odmAdmin"

# ODM admin password
ODM_PASSWORD="odmAdmin"

# ODM service name.  The setup script attempts to find this value so set this only if the script is unable to do so.
ODM_SERVICE_NAME=""

# ODM service nodeport.  The setup script attempts to find this value so set this only if the script is unable to do so.
ODM_NODEPORT=""

# ODM Kubernetes namespace.  The setup script attempts to find this value so set this only if the script is unable to do so.
ODM_NAMESPACE=""


#############################
#  REDIS-RELATED VARIABLES  #
#############################

# Redis Helm chart name
REDIS_CHART="ibm-redis-ha-dev"

# Redis Helm chart version
REDIS_CHART_VERSION="1.1.0"

# Redis Helm release name.  Set this if the Redis chart is installed multiple times to indicate which one to use.  Otherwise leave it blank.
REDIS_RELEASE_NAME=""

# Redis Kubernetes namespace.  The setup script attempts to find this value so set this only if the script is unable to do so.
REDIS_NAMESPACE=""

# Redis service name.  The setup script attempts to find this value so set this only if the script is unable to do so.
REDIS_SERVICE_NAME=""
