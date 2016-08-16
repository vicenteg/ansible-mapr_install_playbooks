#!/bin/sh 

if [ ! -f inventory.py ]; then
	echo "No inventory file."
	exit 1
fi

if jq . < /dev/null ; then
	# print edge node IPs
	./inventory.py | jq '
		(.["edge"] | map("Edge: \(.)")),
		(.["webserver"] | map("MCS: https://\(.):8443")),
		(.["solr"] | map("Solr Admin: http://\(.):8983/solr")),
		(.["opentsdb"] | map("OpenTSDB: http://\(.):4242")),
		(.["hue"] | map("Hue: http://\(.):8888")),
		(.["mesosmaster"] | map("Mesos Masters: http://\(.):5050")),
		(.["mesosmaster"] | map("Marathon: http://\(.):8080")),
		(.["resourcemanager"] | map("Resource Manager: https://\(.):8090"))'
else
	echo "Install jq to use this utility."
fi
