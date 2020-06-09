echo "ls crypto-config/peerOrganizations/org1.example.com/ca"
echo "And copy the sk file (ex: a29e53098e0b4dee6f6e8d7abc07e07a6074db69e822ff3adcc4415f033a1e75_sk)"
echo "Now, open up docker-compose.yml again, and replace the FABRIC_CA_SERVER_CA_KEYFILE sk file in the path with the one you just copied."
echo "Ex. FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/4 239aa0dcd76daeeb8ba0cda701851d14504d31aad1b2ddddbac6a57365e497c_sk"
echo ""
echo "Next, navigate to the sk file for Org2 and do the same thing. It will live in the path:"
echo "./crypto-config/peerOrganizations/org2.example.com/ca"

echo "***********************"
echo ""

echo "Start CA containers"
# docker-compose -f docker-compose.yml up -d Org1ca.example.com Org2ca.example.com

# Start all containers
docker-compose -f docker-compose.yml up -d Org1ca.example.com Org2ca.example.com orderer.example.com couchdbOrg1Peer0 peer0.org1.example.com couchdbOrg1Peer1 peer1.org1.example.com cli

docker exec -it cli bash

rm -f *.pb

rm -f *.json

ls

# echo "start off by grabbing the latest configuration definition from the network"
peer channel fetch config blockFetchedConfig.pb -o orderer.example.com:7050 -c allarewelcome

# echo "Decode the latest configuration definition"
configtxlator proto_decode --input blockFetchedConfig.pb --type common.Block | jq .data.data[0].payload.data.config > configBlock.json

# echo "modify the current configuration file that is on the new to include all our newest orgs"
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org2MSP":.[1]}}}}}' configBlock.json ./config/org2_definition.json > configChanges.json

# echo "confirm that this exists in our directory"
ls 

# echo "confirm the contents were inserted"
cat configChanges.json

# echo "made the appropriate changes, and encode our files, let’s encode the original configuration file back into protobuf"
configtxlator proto_encode --input configBlock.json --type common.Config --output configBlock.pb

# echo "perform the same encoding on our files with the modifications"
configtxlator proto_encode --input configChanges.json --type common.Config --output configChanges.pb

# echo "compute_update allows us to compare our original (unmodified) configuration and our newly modified version to determine changes between the two, rather than doing it manually"
configtxlator compute_update --channel_id allarewelcome --original configBlock.pb --updated configChanges.pb --output configProposal_Org2.pb

# echo " decode it so we can add all of the header-related information on it"
configtxlator proto_decode --input configProposal_Org2.pb --type common.ConfigUpdate | jq . > configProposal_Org2.json

# echo " taking our newly created configuration file, and attaching their original header information around it (also called fitting it in an envelope)"
echo '{"payload":{"header":{"channel_header":{"channel_id":"allarewelcome", "type":2}},"data":{"config_update":'$(cat configProposal_Org2.json)'}}}' | jq . > org2SubmitReady.json

# echo "re-encode it so we can submit it to the network for a configuration"
configtxlator proto_encode --input org2SubmitReady.json --type common.Envelope --output org2SubmitReady.pb

# echo "gather signatures from the majority of admins of Org1 (the org already on the channel)"
peer channel signconfigtx -f org2SubmitReady.pb


# echo "send our changes (aka our update) off to the network for approval"
peer channel update -f org2SubmitReady.pb -c allarewelcome -o orderer.example.com:7050

# echo "exit cli"
exit

# echo "Now we can bring up our Org2 containers."
docker-compose -f docker-compose.yml up -d couchdbOrg2Peer0 peer0.org2.example.com couchdbOrg2Peer1 peer1.org2.example.com

docker exec -it cli bash

export CORE_PEER_LOCALMSPID=Org2MSP

export CORE_PEER_ADDRESS=peer0.org2.example.com:7051

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

# peer channel fetch config Org2AddedConfig.pb -o orderer.example.com:7050 -c allarewelcome
peer channel fetch 0 Org2AddedConfig.block -o orderer.example.com:7050 -c allarewelcome

peer channel join -b Org2AddedConfig.block

peer chaincode install -n ccForAll -v 1.1 -p github.com/sacc

peer chaincode list --installed

peer chaincode upgrade -n ccForAll -v 1.1 -o orderer.example.com:7050 --policy "AND('Org1.peer', 'Org2.peer', OR ('Org1.admin') )"  -c '{"Args":["Mach", "50"]}' -C allarewelcome

peer chaincode list --instantiated -C allarewelcome



export CORE_PEER_LOCALMSPID=Org2MSP

export CORE_PEER_ADDRESS=peer1.org2.example.com:7051

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

# peer channel fetch config Org2AddedConfig.pb -o orderer.example.com:7050 -c allarewelcome
peer channel fetch 0 Org2AddedConfig.block -o orderer.example.com:7050 -c allarewelcome

peer channel join -b Org2AddedConfig.block

peer chaincode install -n ccForAll -v 1.1 -p github.com/sacc

peer chaincode list --installed

peer chaincode list --instantiated -C allarewelcome


# if any errors on any peers of Org2, bring down the container and run all over again to join the channel
# Ex:
# docker container rm -f peer1.org2.example.com
# docker-compose -f docker-compose.yml up -d peer1.org2.example.com

# echo "exit cli"
exit

# cho ""
# echo ""
# echo "******************************"
# echo "Lab 7 run SUCCESSFULLY!"
# echo "******************************"
# echo ""
