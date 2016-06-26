#!/bin/bash

DOCKER_MACHINE="default"
WOTTERDIR="../WOtter"
WOTTERCLIENTDIR="../WOtterClient"
WOTTERDOCKERDIR="`pwd`"

WOTTERWOA="$WOTTERDIR/WOtter/build/WOtter.woa"
WOTTERWOATARGET="$WOTTERDOCKERDIR/web/apps/"

WOTTERCHECKURL="http://wotter-docker/WOTesting/WebObjects/WOtter.woa/rs/swagger.json"

echo Building .woa...
cd "$WOTTERDIR"
./gradlew clean eclipse build || { echo Error building .woa; exit 1; }
cp -r "$WOTTERWOA" "$WOTTERWOATARGET"
EOMODELPATH="$WOTTERWOATARGET/WOtter.woa/Contents/Frameworks/WOtterModel.framework/Resources/WOtterModel.eomodeld/index.eomodeld"
cat "$EOMODELPATH" \
	| sed 's#URL = .*;#URL = "jdbc:postgresql://wotterdocker_postgres_1/";#' \
	| sed 's#username = .*;#username = postgres;#' \
	| sed 's#password = .*;#password = postgres;#' \
	> "${EOMODELPATH}.tmp"
mv "${EOMODELPATH}.tmp" "${EOMODELPATH}"

echo Building docker machine...
cd "$WOTTERDOCKERDIR"
eval $(docker-machine env $DOCKER_MACHINE)
docker-compose down
docker-compose rm -f
docker-compose build || { echo Error building docker; exit 1; }
docker-compose up -d || { echo Error launching docker; exit 1; }

echo Waiting for swagger.json being available
cnt=0
while true
do
	curl -s "$WOTTERCHECKURL" | grep '"swagger":"2.0"' > /dev/null
	if [ $? -eq 0 ]; then break; fi
	cnt=$((cnt+1))
	if [ $cnt -gt 120 ]; then echo .woa not up after 120 seconds; exit 1; fi
	sleep 1;
done

echo Running XCode tests...
cd "$WOTTERCLIENTDIR"
xcodebuild -workspace WOtterClient.xcworkspace \
	-scheme WOtterClient \
	-sdk iphonesimulator \
	-destination 'platform=iOS Simulator,name=iPhone 6,OS=9.3' \
	-derivedDataPath './testOutput' \
	test || { echo Error running tests; exit 1; }

echo Cleaning up...
cd "$WOTTERDOCKERDIR"
docker-compose down
