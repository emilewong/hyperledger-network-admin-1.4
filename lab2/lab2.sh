export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=allarewelcome

# generate crypto material for new peer
cryptogen extend --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

#  check newly created certificates
ls crypto-config/peerOrganizations/org1.example.com/peers

# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "look at this newly created genesis block by using the inspectBlock command"
configtxgen -inspectBlock ./config/genesis.block

echo "use our docker-compose definition to quickly bring up peer1.org1"
docker-compose -f docker-compose.yml up -d peer0.org1.example.com peer1.org1.example.com cli

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}


echo "Fetch the channel for peer1.org1.example.com"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel fetch oldest allarewelcome.block -o orderer.example.com:7050 -c allarewelcome 

echo "Join peer1.org1.example.com to the channel."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel join -b allarewelcome.block

echo "check and see if peer1.org1.example.com is actually joined"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel list


echo ""
echo ""
echo "******************************"
echo "Lab 2 run SUCCESSFULLY!"
echo "******************************"
echo ""

