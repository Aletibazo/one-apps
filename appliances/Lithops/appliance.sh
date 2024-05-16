# ---------------------------------------------------------------------------- #
# Copyright 2024, OpenNebula Project, OpenNebula Systems                  #
#                                                                              #
# Licensed under the Apache License, Version 2.0 (the "License"); you may      #
# not use this file except in compliance with the License. You may obtain      #
# a copy of the License at                                                     #
#                                                                              #
# http://www.apache.org/licenses/LICENSE-2.0                                   #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS,            #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
# ---------------------------------------------------------------------------- #

### Important notes ##################################################
#
# The contextualization variable 'ONEAPP_SITE_HOSTNAME' IS (!) mandatory and
# must be correct (resolveable, reachable) otherwise the web will be broken.
# It defaults to first non-loopback address it finds - if no address is found
# then the 'localhost' is used - and then wordpress will function correctly
# only from within the instance.
#
# 'ONEAPP_SITE_HOSTNAME' can be changed in the wordpress settings but it should
# be set to something sensible from the beginning so you can be able to login
# to the wordpress and change the settings...
#
### Important notes ##################################################


# List of contextualization parameters
ONE_SERVICE_PARAMS=(
    'ONEAPP_BACKEND'                    'configure'  'Lithops compute backend'                                          ''
    'ONEAPP_STORAGE'                    'configure'  'Lithops storage backend'                                          ''
    'ONEAPP_MINIO_ENDPOINT'             'configure'  'Lithops storage backend MinIO endpoint URL'                       ''
    'ONEAPP_MINIO_ACCESS_KEY_ID'        'configure'  'Lithops storage backend MinIO account user access key'            ''
    'ONEAPP_MINIO_SECRET_ACCESS_KEY'    'configure'  'Lithops storage backend MinIO account user secret access key'     ''
    'ONEAPP_MINIO_BUCKETT'              'configure'  'Lithops storage backend MinIO existing bucket'                    ''
)


### Appliance metadata ###############################################

# Appliance metadata
ONE_SERVICE_NAME='Service Lithops - KVM'
ONE_SERVICE_VERSION='3.3.0'   #latest
ONE_SERVICE_BUILD=$(date +%s)
ONE_SERVICE_SHORT_DESCRIPTION='Appliance with preinstalled Lithops for KVM hosts'
ONE_SERVICE_DESCRIPTION=$(cat <<EOF
Appliance with preinstalled latest version of Lithops. 

By default, it uses localhost both for Compute and Storage Backend.

To configure MinIO as Storage Backend use the parameter ONEAPP_STORAGE:minio in conjunction 
with ONEAPP_MINIO_ENDPOINT, ONEAPP_MINIO_ACCESS_KEY_ID and ONEAPP_MINIO_SECRET_ACCESS_KEY. 
These parameters values have to point to a valid and reachable MinIO server endpoint.
The parameter ONEAPP_MINIO_BUCKETT is optional, and it points to an existing bucket in the MinIO
server. If the bucket does not exist or if the parameter is empty, the MinIO server will
generate a bucket automatically.
EOF
)
ONE_SERVICE_RECONFIGURABLE=true

### Contextualization defaults #######################################

ONEAPP_BACKEND="${ONEAPP_BACKEND:-localhost}"
ONEAPP_STORAGE="${ONEAPP_STORAGE:-localhost}"

### Globals ##########################################################

DEP_PKGS="python3-pip"

###############################################################################
###############################################################################
###############################################################################

#
# service implementation
#

service_cleanup()
{
    :
}

service_install()
{
    # ensuring that the setup directory exists
    #TODO: move to service
    mkdir -p "$ONE_SERVICE_SETUP_DIR"

    # packages
    install_pkgs ${DEP_PKGS}

    # wordpress
    install_lithops

    # service metadata
    create_one_service_metadata

    # cleanup
    postinstall_cleanup

    msg info "INSTALLATION FINISHED"

    return 0
}

service_configure()
{
    # create Lithops config file in /etc/lithops
    create_lithops_config
    # update Lithops config file if non-default options are set
    update_lithops_config
    return 0
}

service_bootstrap()
{
    update_lithops_config
    return 0
}

###############################################################################
###############################################################################
###############################################################################

#
# functions
#

install_pkgs()
{
    msg info "Run apt-get update"
    apt-get update

    msg info "Install required packages"
    if ! apt-get install -y "${@}" ; then
        msg error "Package(s) installation failed"
        exit 1
    fi
}

install_lithops()
{
    msg info "Install Lithops from pip"
    if ! pip install lithops ; then
        msg error "Error installing Lithops"
        exit 1
    fi

    msg info "Create /etc/lithops folder"
    mkdir /etc/lithops

    return $?
}

create_lithops_config()
{
    msg info "Create default config file"
    cat > /etc/lithops/config <<EOF
lithops:
  backend: localhost
  storage: localhost

# Start Compute Backend configuration
# End Compute Backend configuration

# Start Storage Backend configuration
# End Storage Backend configuration
EOF
}

update_lithops_config(){
    msg info "Update compute and storage backend modes"
    sed -i "s/backend: .*/backend: ${ONEAPP_BACKEND}/g" /etc/lithops/config
    sed -i "s/storage: .*/storage: ${ONEAPP_STORAGE}/g" /etc/lithops/config

    if [ ${ONEAPP_STORAGE} = "localhost" ]; then
        msg info "Edit config file for localhost Storage Backend"
        sed -i -ne "/# Start Storage/ {p;" -e ":a; n; /# End Storage/ {p; b}; ba}; p" /etc/lithops/config
    elif [ ${ONEAPP_STORAGE} = "minio" ]; then
        msg info "Edit config file for MinIO Storage Backend"
        if ! check_minio_attrs; then
            echo
            msg error "MinIO configuration failed"
            msg info "You have to provide endpoint, access key id and secrec access key to configure MinIO storage backend"
        else
            msg info "Adding MinIO configuration to /etc/lithops/config"
            sed -i -ne "/# Start Storage/ {p; iminio:\n  endpoint: ${ONEAPP_MINIO_ENDPOINT}\n  access_key_id: ${ONEAPP_MINIO_ACCESS_KEY_ID}\n  secret_access_key: ${ONEAPP_MINIO_SECRET_ACCESS_KEY}\n  storage_bucket: ${ONEAPP_MINIO_BUCKETT}" -e ":a; n; /# End Storage/ {p; b}; ba}; p" /etc/lithops/config
        fi
    fi
}

check_minio_attrs()
{
    [ -z "$ONEAPP_MINIO_ENDPOINT" ] && return 1
    [ -z "$ONEAPP_MINIO_ACCESS_KEY_ID" ] && return 1
    [ -z "$ONEAPP_MINIO_SECRET_ACCESS_KEY" ] && return 1

    return 0
}

postinstall_cleanup()
{
    msg info "Delete cache and stored packages"
    apt-get autoclean
    apt-get autoremove
    rm -rf /var/lib/apt/lists/*
}
