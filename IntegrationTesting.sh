
if $IsIntegrationTestingTask -eq "true" ; then
	echo "start Integration testing..."
	curl -XPOST --silent --show-error --user ${TiggerUser}:${TiggerToken} ${TiggerAddress}
fi

GREP_RETURN_CODE=0
sleep 30
for ((i=0; i<=20; i++)); do
	curl --silent ${QueryAddress} | grep result\":\"SUCCESS\" > /dev/null
	GREP_RETURN_CODE=$?
	
	if [ $GREP_RETURN_CODE -eq "0" ] ; then
		echo "Integration testing SUCCESS !"
		if $IsIntegrationTestingTask -eq "true" ; then
		curl --silent ${QueryAddress} | grep -o '"totalCount[^,]*' >tmp.txt
		TOTAL_COUNT=$(<tmp.txt)
		curl --silent ${QueryAddress} | grep -o '"duration[^,]*' >tmp.txt
		DURATION=$(cut -d ":" -f 2 tmp.txt)
		TEST_MIN=$[DURATION / 60 / 1000]
		TEST_SEC=$[DURATION /1000 % 60]
		echo "$TOTAL_COUNT ,duration:$TEST_MIN min $TEST_SEC sec"
		fi
		exit 0
	fi
	curl --silent ${QueryAddress} | grep result\":\"FAILURE\" > /dev/null
	GREP_RETURN_CODE=$?
	if [ $GREP_RETURN_CODE -eq "0" ] ; then	
		echo "Integration testing FAILURE !"
		if $IsIntegrationTestingTask -eq "true" ; then
		curl --silent ${QueryAddress} | grep -o '"totalCount[^,]*' >tmp.txt
		TOTAL_COUNT=$(<tmp.txt)
		curl --silent ${QueryAddress} | grep -o '"failCount[^,]*' >tmp.txt
		FAIL_COUNT=$(<tmp.txt)
		curl --silent ${QueryAddress} | grep -o '"duration[^,]*' >tmp.txt
		DURATION=$(cut -d ":" -f 2 tmp.txt)
		TEST_MIN=$[DURATION / 60 / 1000]
		TEST_SEC=$[DURATION /1000 % 60]
		echo "$TOTAL_COUNT , $FAIL_COUNT ,duration:$TEST_MIN min $TEST_SEC sec"
		fi
		exit 1
	elif [ $i -eq "19" ] ; then
		echo "Integration testing : TIMEOUT"
		exit 1
	else
		echo "wait 60sec."
		sleep 60
	fi
done