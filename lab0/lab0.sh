reset
chmod u+x *.sh
export FABRIC_START_TIMEOUT=5
echo ""
echo "******************************"
echo "stop all containers"
echo "******************************"
echo ""
./stop.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "teardown all containers"
echo "******************************"
echo ""
./teardown.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "Init the sys env"
echo "******************************"
echo ""
./init.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "Generate network artifacts"
echo "******************************"
echo ""
./generate.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "****************************************************"
echo "Start container, create channel, and join channel"
echo "****************************************************"
echo ""
./start.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "Show channel joined"
echo "******************************"
echo ""
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel list
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "stop all containers"
echo "******************************"
echo ""
./stop.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo "******************************"
echo "teardown all containers"
echo "******************************"
echo ""
./teardown.sh
echo "Sleep "${FABRIC_START_TIMEOUT} " seconds"
sleep ${FABRIC_START_TIMEOUT}

echo ""
echo ""
echo "********************************************"
echo "Hyperledger Fabric test run SUCCESSFULLY!"
echo "********************************************"
echo ""