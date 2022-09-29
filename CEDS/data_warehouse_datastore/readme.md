
# Analytics Middle Tier - Contributions

We these scripts we are able to transfer data from the `Ed-Fi Ods` to the [CEDS Data Warehouse](https://github.com/CEDStandards/CEDS-Data-Warehouse)

## Usage Guidelines

1. First step is setting up the connection string configuration. 
To do that, rename the `configuration.json.example` to `configuration.json` file with the appropriate values based on your environment settings. 

3. After that, execute `main.py` script
	```powershell
	py main.py
	```
## Third party modules used

1. [Pyodbc](https://pypi.org/project/pyodbc/)
	Open source module to access ODBC databases.
	```
	pip install pyodbc
	```
2. [Pandas](https://pandas.pydata.org/)
	Data analysis and manipulation tool
	```
	pip install pandas
	```	

## License

Copyright &copy; Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, version 2.0](https://www.ed-fi.org/getting-started/license-ed-fi-technology/) license.