#!/bin/sh
ARCH=`uname -p`
BRIDGE_URL="https://github.com/getbridge/bridge-server/tarball"
RABBIT_URL="https://github.com/downloads/getbridge/bridge-server/rabbitmq-server-2.8.1u."

GET_TO_IT=0
GOT_RABBIT=0

TMP_DIR=$HOME/.bridge
BIN_DIR=${TMP_DIR}/bridge/bc-latest/bin

err() {
    echo "$@" > 2&
    exit 1
}

if [[ $ARCH =~ ^(x86|i[3-6]86)$ ]]; then
    $ARCH = "x86"
elif [ $ARCH != "x86_64" ]; then
    err "My sincerest apologies. I do not know how to deal with your computer's architecture."
fi

prompt() {
    if [[ $GET_TO_IT = "1" ]]; then
	return 1
    fi

    read -r -p "$1 [y/N] " response
    response=${response,,}
    [ ! [[ $response =~ ^(n|no)$ ]] ]
}

echo "Setting up in $TMP_DIR."
mkdir -p $TMP_DIR/tmp

if [ -z "`which rabbitmq-server 2>&1 | grep -P '^/'`" ]; then
    # Acquire rabbit.
    if prompt "I can't seem to find rabbitmq-server in your path. Shall I fetch it for you?"; then
	RABBIT_DIR="${TMP_DIR}/rabbitmq"
	GOT_RABBIT=1
	curl -L -o tmp/rabbitmq.tar.gz "${RABBIT_URL}/${ARCH}.tar.gz"
	
	tar -xzf tmp/rabbitmq.tar.gz
	mv getbridge-rabbit* rabbitmq
    else
	err "Very well, then. I will respect your decision."
    fi
fi

if [ -d $TMP_DIR/bridge-server ]; then
    mv $TMP_DIR/bridge-server $TMP_DIR/bridge-server.old`date +%m%d%H%M%Y.%S`
fi

echo "Downloading and unpacking Bridge from ${BRIDGE_URL}/${ARCH}."
curl -L -o tmp/bridge.tar.gz "${BRIDGE_URL}/${ARCH}"

tar -xzf tmp/bridge.tar.gz
if [ $? != "0" ]; then
    echo "Tar returned with $?"
    err "tar failed!"
fi

mv getbridge-bridge-server-* bridge-server

rm -rf tmp

echo "The installation is now complete. Have a good day, and do put in a good word, will you?"

echo -e "\n To use Bridge, first run the rabbitmq-server:"

if [ $GOT_RABBIT = 1 ]; then
    echo "  Execute \`cd ${RABBIT_DIR}; ./bin/start_epmd; ./bin/start_server\`".
else
    echo "  Execute \`rabbitmq-server\` (if you want, run it with the -detached flag)."
fi

echo -e "\n Then start the bridge server:\n  Execute \`${BIN_DIR}/server start\`"

echo -e "\n To stop the bridge server, simply run \`${BIN_DIR}/bridge/bc-latest/bin/server stop\`"
