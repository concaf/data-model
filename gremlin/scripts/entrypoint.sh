#! /usr/bin/bash

SERVER_DIR=dynamodb-titan-storage-backend/server/dynamodb-titan100-storage-backend-1.0.0-hadoop1/
PROPS=${SERVER_DIR}/conf/gremlin-server/dynamodb.properties
GREMLIN_CONF=${SERVER_DIR}/conf/gremlin-server/gremlin-server.yaml
GREMLIN_HOST=$HOSTNAME
RESPONSE_TIMEOUT=100000
GREMLIN_SERVER_SH=${SERVER_DIR}/bin/gremlin-server.sh
JVM_VALUE="-Xms1024m -Xmx2048m -javaagent:$LIB/jamm-0.3.0.jar"

sed -i.bckp 's#host: .*#host: '$GREMLIN_HOST'#' ${GREMLIN_CONF}
sed -i.bckp 's#storage.dynamodb.client.credentials.class-name=.*#storage.dynamodb.client.credentials.class-name='$1'#' ${PROPS}
sed -i.bckp 's#storage.dynamodb.client.credentials.constructor-args=.*#storage.dynamodb.client.credentials.constructor-args='$2'#' ${PROPS}
sed -i.bckp 's#serializedResponseTimeout: .*#serializedResponseTimeout: '${RESPONSE_TIMEOUT}'#' ${GREMLIN_CONF}

if [ -v aws_region ]; then
  sed -i.bckp 's#storage.dynamodb.client.endpoint=.*#storage.dynamodb.client.endpoint='$aws_region'#' ${PROPS}
fi

if [ "$REST" == "1" ]; then
    sed -i.bckp 's#channelizer: .*#channelizer: org.apache.tinkerpop.gremlin.server.channel.HttpChannelizer#' ${GREMLIN_CONF}
fi

sed -i.bckp 's/^ *#*JAVA_OPTIONS="-Xms32m -Xmx512m -javaagent:$LIB/jamm-0.3.0.jar/"'$JVM_VALUE'/' ${GREMLIN_SERVER_SH}

cd ${SERVER_DIR}

sleep 20

exec bin/gremlin-server.sh conf/gremlin-server/gremlin-server.yaml
