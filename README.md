# ark_affinity
Sets affinity uniquely amongst processes. 


# get_affinity.sh
Gets the affinity of the process
```
root@server:~# sudo ./get_affinity.sh
PID - Command - Affinity
---------------------------------
1611248 ShooterGameServ - CPUs: 0-3
1611249 ShooterGameServ - CPUs: 4-7
1612708 ShooterGameServ - CPUs: 8-11
1613180 ShooterGameServ - CPUs: 12-15
1620092 ShooterGameServ - CPUs: 16-19
```
# set_affinity.sh
Sets the affinity of all found processes containing Shooter, and give them 4 unique cpus

# manage_affinity.sh
- Automatically assigns non-overlapping CPU ranges to each process.
- Identifies and resolves CPU affinity overlaps among processes.
- Maintains a log of all operations, providing insights into changes and errors.
### cron setup
To run every 5 mins
```shell
*/5 * * * * /root/manage_affinity.sh >> /var/log/manage_affinity.log 2>&1
```
