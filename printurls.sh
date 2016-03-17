#!/bin/sh 

if [ ! -f inventory.py ]; then
	echo "No inventory file."
	exit 1
fi

if jq . < /dev/null ; then
	# print edge node IPs
	./inventory.py | jq '.["edge"] | map("Edge node: \(.)")'

	# print MCS URLs
	./inventory.py | jq '.["webserver"] | map("MCS: https://\(.):8443")'

	# print Solr URLs
	./inventory.py | jq '.["solr"] | map("Solr Admin: http://\(.):8983/solr")'

	# print OpenTSDB URLs
	./inventory.py | jq '.["opentsdb"] | map("OpenTSDB: http://\(.):4242")'

	# print Hue URLs
	./inventory.py | jq '.["hue"] | map("Hue: http://\(.):8888")'

	# print Spark URLs
	# ./inventory.py | jq '.["spark_master"] | map("Spark Master: http://\(.):8080")'

	# print Mesos URLs
	./inventory.py | jq '.["mesosmaster"] | map("Mesos Master: http://\(.):8080")'

	# print ResourceManager URLs
	./inventory.py | jq '.["resourcemanager"] | map("Resource Manager: https://\(.):8090")'
else
	echo "Install jq to use this utility."
fi
