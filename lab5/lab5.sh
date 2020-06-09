echo "Use configtxgen command to output an anchor peer transaction"
../bin/configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/changeanchorpeerorg1.tx -channelID allarewelcome -asOrg Org1MSP

echo "Use cli container to implemet this updated transaction"

echo "Remove cli container"
docker container rm -f cli

echo "Bring up cli container again"
docker-compose -f docker-compose.yml up -d cli

echo "Run peer channel update command on cli container, referencing the anchor peer transaction we have created"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" -e "export CORE_PEER_ADDRESS=peer1.org1.example.com:7051" cli peer channel update -o orderer.example.com:7050 -c allarewelcome -f ./config/changeanchorpeerorg1.tx

echo "check the peer logs and see this by exiting the container and running"
docker logs peer1.org1.example.com

echo "Lab 5 run SUCCESSFULLY!"