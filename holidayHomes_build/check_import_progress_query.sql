-- 18/02/2014 MC Query to check import progress

SELECT @@ServerName as [server], * 
FROM holidayHomes_build.import.tab_runLog 
WHERE runId IN (SELECT max(runId) FROM holidayHomes_build.import.tab_runLog)
AND messageType = 'error';

SELECT @@ServerName as [server], * 
FROM holidayHomes_build.import.tab_runLog
WHERE runId IN (SELECT max(runId) FROM holidayHomes_build.import.tab_runLog)
ORDER BY runLogId DESC;