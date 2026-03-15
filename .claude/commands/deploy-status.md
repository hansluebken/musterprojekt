Pruefe den Deployment-Status auf dem Server:

1. Container-Status: `ssh -p 4321 kuenstler@4hl.dev "docker ps | grep $ARGUMENTS"`
2. Letzte Logs: `ssh -p 4321 kuenstler@4hl.dev "docker logs $ARGUMENTS-app 2>&1 | tail -30"`
3. Fasse den Status zusammen (laeuft/gestoppt, Fehler, Uptime)
