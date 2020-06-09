

../bin/configtxgen -profile OrgTwoChannel -outputCreateChannelTx ./config/OrgTwoChannel.tx -channelID orgtwochannel

../bin/configtxgen -profile AllAreWelcomeTwo -outputCreateChannelTx ./config/AllAreWelcomeTwo.tx -channelID allarewelcometwo

ls ./config

docker exec -it cli bash

export CORE_PEER_LOCALMSPID="Org2MSP"

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

export CORE_PEER_ADDRESS=peer1.org2.example.com:7051

peer channel create -o orderer.example.com:7050 -f ./config/AllAreWelcomeTwo.tx -c allarewelcometwo

peer channel create -o orderer.example.com:7050 -f ./config/OrgTwoChannel.tx -c orgtwochannel

peer channel join -o orderer.example.com:7050 -b ./org2channel.block


docker exec -it cli bash
export CORE_PEER_LOCALMSPID=OrdererMSP
export CORE_PEER_ADDRESS=orderer.example.com:7050
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
peer channel fetch config genesis.pb -o orderer.example.com:7050 -c testchainid
configtxlator proto_decode --input genesis.pb --type common.Block | jq .data.data[0].payload.data.config > genesisBlock.json
jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"groups":{"Org2MSP":.[1]}}}}}}}' genesisBlock.json ./config/org2_definition.json > genesisBlockChanges.json
configtxlator proto_encode --input genesisBlock.json --type common.Config --output genesisBlock.pb
configtxlator proto_encode --input genesisBlockChanges.json --type common.Config --output genesisBlockChanges.pb
configtxlator compute_update --channel_id testchainid --original genesisBlock.pb --updated genesisBlockChanges.pb --output genesisBlocProposal_Org2.pb
configtxlator proto_decode --input genesisBlocProposal_Org2.pb --type common.ConfigUpdate | jq . > genesisBlocProposal_Org2.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat genesisBlocProposal_Org2.json)'}}}' | jq . > genesisBlocProposalReady.json
configtxlator proto_encode --input genesisBlocProposalReady.json --type common.Envelope --output genesisBlocProposalReady.pb
peer channel update -f genesisBlocProposalReady.pb -c testchainid -o orderer.example.com:7050