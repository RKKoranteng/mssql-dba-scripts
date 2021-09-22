-- This script will retrive DB Host, SQLServer Port, and SQLServer Instance
-- I needed this info when setting up Oracle DB Gateway for SQLServer 
-- @ https://rkkoranteng.com/2021/09/20/oracle-database-gateway-19c-deployment-for-sql-server/

SELECT 
 @@servername as HostName,
 local_tcp_Port as Port#,
 @@servicename as InstanceName
FROM 
 sys.dm_exec_connections
WHERE 
 local_tcp_port is not null
GROUP BY 
 local_net_address,
 local_tcp_Port
