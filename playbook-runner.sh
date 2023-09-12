#!/bin/bash
#
#

USER="ubuntu"
JENKIN_SECONDARY_PORT=8080
JENKIN_PRIMARY_PORT=3000
TARGET_HOST="staging_server"
HOST_DOMAIN="test-deployment.polymersuite.asia"

ensure_tools_install(){
    ansible-playbook playbooks/ensure_tools_install.yaml -u $USER \
        -e "ansible_user=$USER"\
        -e "target_server=$TARGET_HOST"\
        -e "https_domain_url=$HOST_DOMAIN"

        # -e "NODE_VERSION=18"
        # -e "ssl_admin_email=lusomreth@gmail.com"\
}

build_jenkin_image(){
    ansible-playbook playbooks/spin_up_jenkin.yaml -u $USER \
        -e "JENKINS_HOME=jenkins_server"\
        -e "target_server=$TARGET_HOST"\
        -e "ansible_user=$USER"
}



run_jenkin_server(){
    ansible-playbook playbooks/run_jenkin_server.yaml -u $USER \
        -e "JENKINS_HOME=jenkins_server"\
        -e "target_server=$TARGET_HOST"\
        -e "ansible_user=$USER"\
        -e "PRIMARY_PORT=${JENKIN_PRIMARY_PORT}"\
        -e "SECONDARY_PORT=${JENKIN_SECONDARY_PORT}"
}

add_ssl(){
    ansible-playbook playbooks/nginx_reverse_proxy.yaml -u $USER \
        -e  "target_server=$TARGET_HOST"\
        -e "https_domain_url=$HOST_DOMAIN" \
        -e "port=${JENKIN_PRIMARY_PORT}"

    ansible-playbook playbooks/add_ssl_encryption.yaml -u $USER \
        -e  "target_server=$TARGET_HOST"\
        -e  "ssl_admin_email=lusomreth@gmail.com" \
        -e  "https_domain_url=$HOST_DOMAIN"\
        -e "FORCE_RENEWAL=1"

}


case "$1" in 
    "install-tool" )
        ensure_tools_install;;
    "setup-jenkin" )
        build_jenkin_image ;;
    "run-jenkin-server" )
        run_jenkin_server;;
    "setup-ssl" ) 
        add_ssl ;;
    * )
        echo "Unknown command: $1"
esac
