echo ""
echo "******************************"
echo "Bootstrap the lab"
echo "******************************"
echo ""
chmod u+x ../bootstrap.sh
../bootstrap.sh
sleep 5

echo ""
echo "*************************************************"
echo "Show channel joined of peer0.org1.example.com"
echo "*************************************************"
echo ""
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel list

echo ""
echo ""
echo "******************************"
echo "Lab 1 run SUCCESSFULLY!"
echo "******************************"
echo ""
