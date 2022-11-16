Node Creation
=============
+ Install the machine from Debian autoinstall image
+ Download this directory into it and run conf.sh
+ chiave and chiave.pub are the keys for node -> master connection
+ cisnodekey and cisnodekey.pub are the keys for master -> node connection
+ Login as root
+ Insert master's IP address when required so local_nodes file will be updated
+ Changing filenames requires changing components/Variables

TODO
====
+ *add launch_docker_job.sh in components* 		Done?
+ *test it*		Done?
+ *deny change directory by sftp/scp/... (should stay on JOBS)* 	(Now only <master> can access only cisnode@<node> with publickey)
