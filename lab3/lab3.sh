echo  "start Fabric containers. "
docker-compose -f docker-compose.yml up -d ca.example.com orderer.example.com couchdbOrg1Peer0 peer0.org1.example.com couchdbOrg1Peer1 peer1.org1.example.com cli

echo "list our running couchDB containers." 
docker ps --filter "name=couchdb"

echo "please confirm your peers are still a part of the channel. If they are not, it may be as result of us re-starting our peers, we may need to rerun the commands"

echo "Fetch the channel for peer0"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel fetch oldest allarewelcome.block -o orderer.example.com:7050 -c allarewelcome 

echo "Join peer0.org1.example.com to the channel."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b allarewelcome.block

echo "Fetch the channel for peer1"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel fetch oldest allarewelcome.block -o orderer.example.com:7050 -c allarewelcome 

echo "Join peer1.org1.example.com to the channel."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel join -b allarewelcome.block

echo "List channels peer1.org1.example.com joined."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel list



cho ""
echo ""
echo "******************************"
echo "Lab 3 run SUCCESSFULLY!"
echo "******************************"
echo ""