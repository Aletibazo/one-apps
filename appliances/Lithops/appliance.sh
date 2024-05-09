# ---------------------------------------------------------------------------- #
# Copyright 2018-2024, OpenNebula Project, OpenNebula Systems                  #
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

)


### Appliance metadata ###############################################

# Appliance metadata
ONE_SERVICE_NAME='Service Lithops - KVM'
ONE_SERVICE_VERSION='3.3.0'   #latest
ONE_SERVICE_BUILD=$(date +%s)
ONE_SERVICE_SHORT_DESCRIPTION='Appliance with preinstalled Lithops for KVM hosts'
ONE_SERVICE_DESCRIPTION=$(cat <<EOF
Appliance with preinstalled Lithops. 

TODO Add complete documentation
EOF
)


### Contextualization defaults #######################################


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
    install_lithops "${ONE_SERVICE_VERSION}"

    # service metadata
    create_one_service_metadata

    # cleanup
    postinstall_cleanup

    msg info "INSTALLATION FINISHED"

    return 0
}

service_configure()
{
    return 0
}

service_bootstrap()
{
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

    return $?
}

postinstall_cleanup()
{
    msg info "Delete cache and stored packages"
    apt-get autoclean
    apt-get autoremove
    rm -rf /var/lib/apt/lists/*
}
