#!/bin/bash

# Configuration ##############################################################
# SCRIPT_DIR: path to directory containing preview_processor.rb, mime types
# PASSWORD_FILE: path to file containing: system_url admin_password
# PROCESSING_URL: url path to json containing items to be processed
SCRIPT_DIR="/home/rsmart/nakamura/scripts";
PASSWORD_FILE="/home/rsmart/.acad_credentials.txt";
PROCESSING_URL="var/search/needsprocessing.json";
##############################################################################

# Treat unset variables as an error when performing parameter expansion
set -o nounset

# Pre-flight checks ##########################################################
# Check password file exists:
if [ ! -f ${PASSWORD_FILE} ] ; then
    echo "ERROR: No file found containing sakai oae credentials";
    exit 1;
fi

# Check password file is not group / world readable:
check_permissions=`find ${PASSWORD_FILE} -perm 0600 | wc -l`;
if [ "${check_permissions}" != "1" ] ; then
    echo "WARN: Permissions on sakai oae credentials file are too liberal.";
    echo "INFO: Attempting to fix permissions on sakai oae credentials file";
    chmod 600 ${PASSWORD_FILE};
    if [ "${?}" != "0" ] ; then
        echo "ERROR: Permissions on sakai oae credentials file broken";
        exit 2;
    fi
fi

# Parse password file - should contain sakai oae system url and admin password
# separated by space:
SAKAIOAE_URL=`cat ${PASSWORD_FILE} | cut -d' ' -f1`
PASSWORD=`cat ${PASSWORD_FILE} | cut -d' ' -f2`;

if [ "${SAKAIOAE_URL}" = "" -o "${PASSWORD}" = "" ] ; then
    echo "ERROR: failure retrieving credentials";
    exit 3;
fi

# Make sure the sakai oae url specified has a trailing slash provided:
check_sakaioae_url=`echo ${SAKAIOAE_URL} | grep '/$'`;

if [ "${?}" != "0" ] ; then
    echo "ERROR: Sakai OAE URL in ${PASSWORD_FILE} does not have a trailing '/'";
    exit 4;
fi

# Make sure open office is running:
check_oo_running=`ps aux | grep program/soffice.bin | grep -v grep`;

if [ "${?}" != "0" ] ; then
    echo "ERROR: open office not running!";
    exit 5;
fi
##############################################################################


# Main action ###############################################################
# Enter the script directory first:
pushd ${SCRIPT_DIR} > /dev/null;

# Check for lock file:
if [ -f ${SCRIPT_DIR}/contentpreview.lock ] ; then
    echo "WARN: previous content preview process did not complete in 60 seconds";
    exit 6;
fi

# Create lock file:
touch ${SCRIPT_DIR}/.contentpreview.lock;

# Issue a head request just to sanity check the needs processing url:
check_processing_url=`curl --insecure --head --silent ${SAKAIOAE_URL}${PROCESSING_URL} | grep " 200 OK"`;

if [ "${?}" = "0" ] ; then
    # Run the preview processol:
    ruby ${SCRIPT_DIR}/preview_processor.rb ${SAKAIOAE_URL} ${PASSWORD} | grep -v "^I,";
    # ruby scripts return 1 on success:
    ruby_return_code=${?};
    if [ "${ruby_return_code}" = "1" ] ; then
        touch ${SCRIPT_DIR}/.contentpreview.success;
    else
        echo "ERROR: ruby ${SCRIPT_DIR}/preview_processor.rb returned non-one exit code: '${ruby_return_code}'";
        rm -f ${SCRIPT_DIR}/.contentpreview.lock;
        exit 7;
    fi
fi

rm -f ${SCRIPT_DIR}/.contentpreview.lock;
# Lock file released.

# Check whether we have seen a successful run in the last ten minutes or not:
if [ -f ${SCRIPT_DIR}/.contentpreview.success ] ; then
    check_last_success_age=`find ${SCRIPT_DIR}/.contentpreview.success -mmin -10 | wc -l`
    if [ "${check_last_success_age}" = "0" ] ; then
        echo "WARN: No successful content preview run for at least 10 minutes";
        exit 8;
    fi
fi

popd > /dev/null;
##############################################################################

exit 0;

