ovs-api
=======

WARNING : this is still a work in progress...

ovs-api is an open source client for the French website OnVaSortir.com which serves the information in the form of a clean and fast JSON API.

It consists of two components : a scrapper and an API server.

The scrapper
------------

The scrapper connects to an OVS account and retrieves a limited number of next events and information.
It stores the information in a Redis server.

The API server
--------------

The API server serves the information stored in the Redis server from the scrapper in JSON responses.
