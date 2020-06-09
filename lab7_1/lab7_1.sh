echo "use cryptogen to generate certificates (without removing the other certificates already generated)"
../bin/cryptogen extend --config=./crypto-config.yaml

echo "check two crypto-certificates folders of peers in Org2"
ls crypto-config/peerOrganizations

echo "take our org definition and put it in a file, so we can later reference it"
../bin/configtxgen -printOrg Org2MSP > ./config/org2_definition.json