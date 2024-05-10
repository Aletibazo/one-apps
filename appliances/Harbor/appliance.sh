# ---------------------------------------------------------------------------- #
<<<<<<< HEAD
# Copyright 2024, OpenNebula Project, OpenNebula Systems                       #
=======
# Copyright 2024, OpenNebula Project, OpenNebula Systems                  #
>>>>>>> c78c970 (F #79: Harbor appliance)
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

# Harbor Docker Registry Appliance for OpenNebula Marketplace

### Utility Functions

gen_db_password() {
    # In case of password losing, it can be retrieved from the harbor-db container root environment variables
    tr -dc A-Za-z0-9 </dev/urandom | head -c 20; echo
}


<<<<<<< HEAD
# ------------------------------------------------------------------------------
# List of contextualization parameters
# ------------------------------------------------------------------------------
ONE_SERVICE_PARAMS=(
    'ONEAPP_HARBOR_ADMIN_PASSWORD' 'configure' 'Harbor admin password'           'O|password'
    'ONEAPP_HARBOR_DB_PASSWORD'    'configure' 'Harbor database password'        'O|password'
    'ONEAPP_HARBOR_HOSTNAME'       'configure' 'Harbor hostname/IP for cert CN'  'O|text'
    'ONEAPP_HARBOR_SSL_CERT'       'configure' 'SSL certificate (.crt)'          'O|text64'
    'ONEAPP_HARBOR_SSL_KEY'        'configure' 'SSL key (.key)'                  'O|text64'
    'ONEAPP_HARBOR_REGISTRY_DEV'   'configure' 'Harbor device for registry data' 'O|text'
)

# ------------------------------------------------------------------------------
# Appliance metadata
# ------------------------------------------------------------------------------
=======
# List of contextualization parameters #######################################
ONE_SERVICE_PARAMS=(
    'HARBOR_ADMIN_PASSWORD'     'configure' 'Harbor admin password'                             'O|password'
    'HARBOR_DB_PASSWORD'        'configure' 'Harbor database password'                          'O|password'
    'HARBOR_HOSTNAME'           'configure' 'Harbor hostname/IP'                                'O|text'
    'HARBOR_SSL_CERT'           'configure' 'SSL certificate (.crt)'                            'O|text64'
    'HARBOR_SSL_KEY'            'configure' 'SSL key (.key)'                                    'O|text64'
    'HARBOR_PERSISTENT_DEV'     'configure' 'Harbor data persistent device (sda, vda, etc.)'    'O|text'
)

### Appliance metadata ###############################################
>>>>>>> c78c970 (F #79: Harbor appliance)

# Appliance metadata
ONE_SERVICE_NAME='Service Harbor - KVM'
ONE_SERVICE_VERSION='2.9.4'   #latest
ONE_SERVICE_BUILD=$(date +%s)
<<<<<<< HEAD
ONE_SERVICE_SHORT_DESCRIPTION='Appliance running Harbor Docker repository'
=======
ONE_SERVICE_SHORT_DESCRIPTION='Appliance running Harbor Docker repository for KVM hosts'
>>>>>>> c78c970 (F #79: Harbor appliance)
ONE_SERVICE_DESCRIPTION=$(cat <<EOF
Appliance with preinstalled Harbor. Run with default values and manually
configure it, or use contextualization variables to automate the bootstrap.

After deploying the appliance, check the status of the deployment in
/etc/one-appliance/status. You chan check the appliance logs in
/var/log/one-appliance/.

In order to configure data persistency, please arrach a secondary disk to the
<<<<<<< HEAD
VM, indicate the disk label in ONEAPP_HARBOR_REGISTRY_DEV and launch the appliance.

**WARNING: Do not use localhost or loopback for \`ONEAPP_HARBOR_HOSTNAME\`, it
breaks the service bootstrap. It's necessary to provide a routable name
or IP. If not provided, it will use the main VM IP.**

=======
VM, indicate the disk label in HARBOR_PERSISTENT_DEV and launch the appliance.

**WARNING: Do not use localhost or loopback for \`HARBOR_HOSTNAME\`, it
breaks the service bootstrap. It's necessary to provide a routable name
or IP. If not provided, it will use the main VM IP.**


>>>>>>> c78c970 (F #79: Harbor appliance)
**WARNING: The appliance does not permit recontextualization. Modifying the
context variables will not have any real efects on the running instance.**
EOF
)

<<<<<<< HEAD
# ------------------------------------------------------------------------------
# Contextualization defaults
#  - "AG", is for "AutoGenerated" certs
# ------------------------------------------------------------------------------
HARBOR_ADMIN_PASSWORD="${ONEAPP_HARBOR_ADMIN_PASSWORD:-Harbor12345}"
HARBOR_DB_PASSWORD="${ONEAPP_HARBOR_DB_PASSWORD:-$(gen_db_password)}"
HARBOR_HOSTNAME="${ONEAPP_HARBOR_HOSTNAME:-$(get_local_ip)}"
HARBOR_SSL_CERT="${ONEAPP_HARBOR_SSL_CERT:-AG}"
HARBOR_SSL_KEY="${ONEAPP_HARBOR_SSL_KEY:-AG}"
HARBOR_REGISTRY_DEV="${ONEAPP_HARBOR_REGISTRY_DEV:-None}"

# ------------------------------------------------------------------------------
# Installation Stage => Installs requirements, downloads and unpacks Harbor
# ------------------------------------------------------------------------------
=======


### Contextualization defaults #######################################
HARBOR_ADMIN_PASSWORD="${HARBOR_ADMIN_PASSWORD:-Harbor12345}"  # Default Harbor admin password
HARBOR_DB_PASSWORD="${HARBOR_DB_PASSWORD:-$(gen_db_password)}" # Defaults to autogenerated password
HARBOR_HOSTNAME="${HARBOR_HOSTNAME:-$(get_local_ip)}" # Listens in all interfaces by default
HARBOR_SSL_CERT="${HARBOR_SSL_CERT:-AG}" # Defaults to "AG", indicating "AutoGenerated"
HARBOR_SSL_KEY="${HARBOR_SSL_KEY:-AG}" # Defaults to "AG", indicating "AutoGenerated"
HARBOR_PERSISTENT_DEV="${HARBOR_PERSISTENT_DEV:-None}" # Listens in all interfaces by default


### Installation Stage => Installs requirements, downloads and unpacks Harbor
>>>>>>> c78c970 (F #79: Harbor appliance)
service_install() {
    msg info "Checking internet access..."
    check_internet_access
    install_requirements
    download_unpack_harbor
    create_one_service_metadata
    msg info "Installation phase finished"
}

<<<<<<< HEAD
# ------------------------------------------------------------------------------
# Configuration Stage => Configures Harbor YAML and SSL certificates
# ------------------------------------------------------------------------------
=======
### Configuration Stage => Configures Harbor YAML and SSL certificates
>>>>>>> c78c970 (F #79: Harbor appliance)
service_configure() {
    msg info "Starting configuration..."
    mount_persistent

    ## SSL CERTS

    mkdir -p /root/certs

    # If one of both files (cert or key) does not exist...
    if [ ! -f "/root/certs/server.crt" ] || [ ! -f "/root/certs/server.key" ]; then
        if [ "$HARBOR_SSL_CERT" = "AG" ] || [ "$HARBOR_SSL_KEY" = "AG" ]; then
            msg info "Autogenerating SSL certificates..."
            generate_ssl_certs
        else
            msg info "Configuring provided SSL certificates..."
            echo $HARBOR_SSL_CERT | base64 --decode >> /root/certs/server.crt
            echo $HARBOR_SSL_KEY | base64 --decode >> /root/certs/server.key
        fi
    else
        msg info "The certificates already exist"
<<<<<<< HEAD
        msg info "This appliance is not prepared for reconfiguration. Skipping..."
=======
        msg info "Recontextualization detected. This appliance is not prepared for reconfiguration. Skipping..."
>>>>>>> c78c970 (F #79: Harbor appliance)
        return 1
    fi

    msg info "Configuring Harbor YAML file..."

    gawk -i inplace -v cert="/root/certs/server.crt" -v key="/root/certs/server.key" -v hostname="$HARBOR_HOSTNAME" '
    {
        if ($1 == "certificate:") {
            print "  certificate:", cert
        } else if ($1 == "private_key:") {
            print "  private_key:", key
        } else if ($1 == "hostname:") {
            print "hostname:", hostname
        } else {
            print
        }
    }' /root/harbor/harbor.yml

    gawk -i inplace -v admin_pwd="$HARBOR_ADMIN_PASSWORD" -v db_pwd="$HARBOR_DB_PASSWORD" '
    {
        if ($1 == "harbor_admin_password:") {
            print "harbor_admin_password:", admin_pwd
        } else if ($1 == "password:") {
            print "  password:", db_pwd
        } else {
            print
        }
    }' /root/harbor/harbor.yml
<<<<<<< HEAD

    msg info "Configuration phase finished"
}

# Running Harbor installer => will generate and run docker-compose
service_bootstrap() {
    msg info "Starting bootstrap..."

    /root/harbor/install.sh

=======
    msg info "Configuration phase finished"
}

service_bootstrap() { # Running Harbor installer => will generate and run docker-compose
    msg info "Starting bootstrap..."
    /root/harbor/install.sh
>>>>>>> c78c970 (F #79: Harbor appliance)
    if [ $? -ne 0 ]; then
        msg error "Harbor installation script failed, aborting..."
        exit 1
    else
        msg info "Harbor installation script finished successfully. Waiting 30s before final health checks..."
    fi
<<<<<<< HEAD

    sleep 30

    msg info "Running final health checks..."

    wait_for_docker_containers

    cleanup_installation

    msg info "Bootstrap phase finished"
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Function Definitions
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
=======
    sleep 30
    msg info "Running final health checks..."
    wait_for_docker_containers
    cleanup_installation
    msg info "Bootstrap phase finished"
}

### Function Definitions

>>>>>>> c78c970 (F #79: Harbor appliance)
check_internet_access() {
    # Ping Google's public DNS server
    if ping -c 1 8.8.8.8 &> /dev/null; then
        msg info "Internet access OK"
        return 0
    else
        msg error "The VM does not have internet access. Aborting Harbor deployment..."
        exit 1
    fi
}

install_requirements(){
    export DEBIAN_FRONTEND=noninteractive
<<<<<<< HEAD

    apt-get update && apt-get install openssl ca-certificates curl gnupg docker.io docker-compose -y

=======
    apt-get update && apt-get install openssl ca-certificates curl gnupg docker.io docker-compose -y
>>>>>>> c78c970 (F #79: Harbor appliance)
    if [ $? -eq 0 ]; then
        msg info "Dependencies installation finished successfully. Running extra checks..."
    else
        msg error "Dependencies installation failed. Aborting..."
    fi
<<<<<<< HEAD

    check_docker

=======
    check_docker
>>>>>>> c78c970 (F #79: Harbor appliance)
    check_docker_compose
}

check_docker() {
    msg info "Checking if Docker is installed and running..."
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
    if ! command -v docker &> /dev/null; then
        msg error "Docker could not be found, Docker installation failed..."
    else
        msg info "Docker is installed, ensuring it is running..."
<<<<<<< HEAD

        if ! systemctl is-active --quiet docker; then
            msg warning "Docker is not running, attempting to start Docker..."

=======
        if ! systemctl is-active --quiet docker; then
            msg warning "Docker is not running, attempting to start Docker..."
>>>>>>> c78c970 (F #79: Harbor appliance)
            systemctl start docker
            systemctl enable docker
            sleep 5
        fi
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
        if ! systemctl is-active --quiet docker; then
            msg error "Failed to start Docker"
            exit 1
        else
            msg info "Docker is running"
            return 0
        fi
    fi
}

check_docker_compose() {
    msg info "Checking if docker-compose is installed..."
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
    if ! command -v docker-compose &> /dev/null; then
        msg error "docker-compose could not be found, aborting..."
        exit 1
    else
        msg info "docker-compose is installed"
        return 0
    fi
}



generate_ssl_certs() {
    if [ -z "${HARBOR_HOSTNAME}" ]; then
<<<<<<< HEAD
        msg info "ONEAPP_HARBOR_HOSTNAME is not set or is empty. Generating certs with 'example.com'"
        HARBOR_HOSTNAME=example.com
    fi

    openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 \
    -keyout /root/certs/server.key -out /root/certs/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$HARBOR_HOSTNAME"

=======
        msg info "HARBOR_HOSTNAME is not set or is empty. Generating certs with 'example.com'"
        HARBOR_HOSTNAME=example.com
    fi
    openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 \
    -keyout /root/certs/server.key -out /root/certs/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$HARBOR_HOSTNAME"
>>>>>>> c78c970 (F #79: Harbor appliance)
    if [ $? -eq 0 ]; then
        msg info "Certificate generated successfully"
    else
        msg info "Error generating SSL certificate. Resuming..."
    fi
}


download_unpack_harbor() {
    msg info "Downloading Harbor..."
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
    # Obtain download URL
    url=$(curl -f -s https://api.github.com/repos/goharbor/harbor/releases/latest \
    | grep browser_download_url \
    | cut -d '"' -f 4 \
    | grep '\.tgz$' \
    | grep offline)

    # Check all pipe exit codes
    for status in "${PIPESTATUS[@]}"; do
        if [ "$status" -ne 0 ]; then
            msg error "Unable to obtain Harbor download URL, aborting..."
            exit 1
        fi
    done

    # Download Harbor
    wget -P /root/ $url
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
    if [ $? -ne 0 ]; then
        msg info "Harbor download failed. Download URL: $url"
        exit 1
    else
        msg info "Harbor downloaded successfully"
    fi
<<<<<<< HEAD

    tar -xvzf /root/harbor-offline-installer-v*.tgz

=======
    tar -xvzf /root/harbor-offline-installer-v*.tgz
>>>>>>> c78c970 (F #79: Harbor appliance)
    if [ $? -ne 0 ]; then
        msg info "Harbor unpacking failed. Aborting..."
        exit 1
    else
        msg info "Harbor unpacked successfully"
    fi
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
    cp /root/harbor/harbor.yml.tmpl /root/harbor/harbor.yml
}


mount_persistent() {
    # Create /data directory
    mkdir -p /data

    # Check if the user provided a persistent device
<<<<<<< HEAD
    if [ "$HARBOR_REGISTRY_DEV" = "None" ]; then
        msg warning "No registry device specified. OS disk will be used to save Harbor data."
=======
    if [ "$HARBOR_PERSISTENT_DEV" = "None" ]; then
        msg warning "No persistent device specified. Persistency can not be ensured. OS disk will be used to save Harbor data."
>>>>>>> c78c970 (F #79: Harbor appliance)
        return 0
    fi

    # Check if the provided device exists
<<<<<<< HEAD
    if ! [ -e "/dev/$HARBOR_REGISTRY_DEV" ]; then
        msg error "Registry device /dev/$HARBOR_REGISTRY_DEV not found. Aborting..."
    fi

    msg info "Registry disk (/dev/$HARBOR_REGISTRY_DEV) detected"

    # Check if already mounted
    if $(cat /proc/mounts | grep -qs /dev/$HARBOR_REGISTRY_DEV); then
        msg info "/dev/$HARBOR_REGISTRY_DEV is already mounted."
        return 0
    fi

    msg info "/dev/$HARBOR_REGISTRY_DEV not mounted"

    # Checking if the device contains a filesystem
    if ! blkid -s TYPE -o value /dev/$HARBOR_REGISTRY_DEV; then
        msg error "Unable to obtain registry disk FS type. Please, create a filesystem first"
    fi

    # Saving FS type
    FS_TYPE=$(blkid /dev/$HARBOR_REGISTRY_DEV --match-tag TYPE -o value)
    msg info "Detected filesystem type $FS_TYPE for persistent device /dev/$HARBOR_REGISTRY_DEV"

    # Add entry to /etc/fstab for persistence
    echo "/dev/$HARBOR_REGISTRY_DEV   /data   $FS_TYPE   defaults   0   2" | tee -a /etc/fstab > /dev/null

    msg info "Added entry to /etc/fstab for registry disk. Mounting..."

=======
    if ! [ -e "/dev/$HARBOR_PERSISTENT_DEV" ]; then
        msg error "PERSISTENT DEVICE /dev/$HARBOR_PERSISTENT_DEV NOT FOUND. Aborting..."
    fi
    msg info "Persistent disk (/dev/$HARBOR_PERSISTENT_DEV) detected"

    # Check if already mounted
    if $(cat /proc/mounts | grep -qs /dev/$HARBOR_PERSISTENT_DEV); then
        msg info "/dev/$HARBOR_PERSISTENT_DEV is already mounted."
        return 0
    fi
    msg info "/dev/$HARBOR_PERSISTENT_DEV not yet mounted"

    # Checking if the device contains a filesystem

    if ! blkid -s TYPE -o value /dev/$HARBOR_PERSISTENT_DEV; then
        msg error "Unable to obtain persistend disk FS type. Please, make sure that the persistent device has a filesystem configured"
    fi

    # Saving FS type
    FS_TYPE=$(blkid /dev/$HARBOR_PERSISTENT_DEV --match-tag TYPE -o value)
    msg info "Detected filesystem type $FS_TYPE for persistent device /dev/$HARBOR_PERSISTENT_DEV"

    # Add entry to /etc/fstab for persistence
    echo "/dev/$HARBOR_PERSISTENT_DEV   /data   $FS_TYPE   defaults   0   2" | tee -a /etc/fstab > /dev/null
    msg info "Added entry to /etc/fstab for persistency. Mounting..."
>>>>>>> c78c970 (F #79: Harbor appliance)
    # Mount the drive
    mount -a
    if [ $? -ne 0 ]; then
        msg error "Unable to mount persistent device, aborting..."
        exit 1
    fi

<<<<<<< HEAD
    msg info "Mounted /dev/$HARBOR_REGISTRY_DEV in /data successfully."
=======
    msg info "Mounted /dev/$HARBOR_PERSISTENT_DEV to /data successfully."
>>>>>>> c78c970 (F #79: Harbor appliance)
}


wait_for_docker_containers() {
    local start_time=$(date +%s)
    local end_time=$((start_time + 300))  # 5 minutes in seconds

    while [ $(date +%s) -lt $end_time ]; do
        local all_healthy=1

        # Get the IDs of all running containers
        local container_ids=$(docker ps --format "{{.ID}}")

        # Iterate through each container ID to check its health
        for container_id in $container_ids; do
            local health=$(docker inspect --format "{{.State.Health.Status}}" "$container_id")
<<<<<<< HEAD

=======
>>>>>>> c78c970 (F #79: Harbor appliance)
            # Check if the container is healthy
            if [ "$health" != "healthy" ]; then
                all_healthy=0
                break  # Break out of the loop if any container is not healthy
            fi
        done

        if [ $all_healthy -eq 1 ]; then
            msg info "All Docker containers are healthy."
            return 0  # All containers are healthy, exit successfully
        fi

        # Sleep for 5 seconds before checking again
        sleep 5
    done

    # If execution reaches here, some containers are still unhealthy after 5 minutes
    msg warning "Some Docker containers are not healthy after 5 minutes."
}



cleanup_installation() {
    msg info "Cleaning up installation residues..."
    apt-get clean
    rm /root/harbor-offline-installer-v*.tgz
}
