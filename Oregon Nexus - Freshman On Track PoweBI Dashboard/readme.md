# Contribution Template


## Brief Description
A series of views, tables and procedure to help with denormalize and aggregate the data for use with the Freshmen On Truck PowerBI Dashboard. 

## Support ODS/AMT Versions

* ODS 3.1.1 
* AMT v2 (March 2020)

## Assumptions
We were looking for a quick and easy way to build a PowerBI Dashboard without moving the data out of the production ODS. 
With the help of AMT which provided the base for our project, we built a series of views to aggregate the data we needed. The stored procedure uses the view to populate the staging tables that are then used by the PowerBI Dashboard.
The idea was that the procedure can be scheduled to run nighly.

## Contact Information (optional)
For more information on this project please contact:

Virgil Hretcanu (Education Nexus Oregon)
vhretcanu@nwresd.k12.or.us