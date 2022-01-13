#!/bin/bash

# Default variables
BASE_IMAGE=ubuntu:20.04
DOCKER_PATH=$(dirname $0)
NAMESPACE=${NAMESPACE:-tdengine}
PREFIX=${PREFIX:-tdengine}
BAILONGMA_VERSION=${BAILONGMA_VERSION:-0.2.2}
PUSH=0
USE_GIT=0

# Parse options
while getopts "pgv:n:P:h" opt; do
  case $opt in
  p)
    PUSH=1
    ;;
  g)
    USE_GIT=1
    ;;
  v)
    VERSION=$OPTARG
    ;;
  n)
    NAMESPACE=$OPTARG
    ;;
  P)
    PREFIX=$OPTARG
    ;;
  h)
    echo "Docker build scripts for TDengine images matrix."
    printf "Usage:\n\t"
    echo "$0 [-p] [-v <version>] [-n <namespace>] [-P <prefix>] [-h]"
    exit 0
    ;;
  ?)
    echo "there is unrecognized parameter." [$*]
    exit 1
    ;;
  esac
done

IMAGE_PREFIX=${NAMESPACE}/$PREFIX
if [ "$VERSION" = "" ]; then
  echo "VERSION variable must be setted!"
  exit 1
fi

cd $DOCKER_PATH
cd builder

#[ -e "ver-$VERSION.tar.gz" ] || wget -c https://github.com/taosdata/TDengine/archive/refs/tags/ver-$VERSION.tar.gz

ORIG_VERSION=$VERSION
VERSION=${VERSION%-beta}
docker build \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg VERSION=$ORIG_VERSION \
  -t $IMAGE_PREFIX-artifacts:$VERSION .
cd ..
cd runtime
docker build \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  -t $IMAGE_PREFIX-runtime .
cd ..
cd server
docker build \
  --build-arg IMAGE_PREFIX=$IMAGE_PREFIX \
  --build-arg VERSION=$VERSION \
  -t $IMAGE_PREFIX-server:$VERSION .
cd ..

cd arbitrator
docker build \
  --build-arg IMAGE_PREFIX=$IMAGE_PREFIX \
  --build-arg VERSION=$VERSION \
  -t $IMAGE_PREFIX-arbitrator:$VERSION .
cd ..

cd client
docker build \
  --build-arg IMAGE_PREFIX=$IMAGE_PREFIX \
  --build-arg VERSION=$VERSION \
  -t $IMAGE_PREFIX-client:$VERSION .
cd ..

cd bailongma
[ -e "bailongma-$BAILONGMA_VERSION" ] || wget -c -O bailongma-$BAILONGMA_VERSION https://github.com/taosdata/bailongma-rs/releases/download/v${BAILONGMA_VERSION}/bailongma-amd64
chmod +x bailongma-$BAILONGMA_VERSION
docker build \
  --build-arg IMAGE_PREFIX=$IMAGE_PREFIX \
  --build-arg VERSION=$VERSION \
  --build-arg BAILONGMA_VERSION=$BAILONGMA_VERSION \
  -t $IMAGE_PREFIX-bailongma:$VERSION-v$BAILONGMA_VERSION .
docker tag $IMAGE_PREFIX-bailongma:$VERSION-v$BAILONGMA_VERSION $IMAGE_PREFIX-bailongma:$VERSION
cd ..

if [ $PUSH -eq 1 ]; then
  docker push $IMAGE_PREFIX-artifacts:$VERSION
  docker push $IMAGE_PREFIX-server:$VERSION
  docker push $IMAGE_PREFIX-arbitrator:$VERSION
  docker push $IMAGE_PREFIX-client:$VERSION
  docker push $IMAGE_PREFIX-bailongma:$VERSION
  docker push $IMAGE_PREFIX-bailongma:$VERSION-v$BAILONGMA_VERSION
fi
