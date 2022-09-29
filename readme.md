# Analytics Middle Tier - Contributions

The Analytics Middle Tier Contribution projects are contributed views and collections the Ed-Fi community has used to pull information out of Ed-Fi. For more information on Analytics Middle Tier:

* [Overview](https://techdocs.ed-fi.org/display/EDFITOOLS/AMT+Overview)
* [Documentation Site](https://techdocs.ed-fi.org/display/EDFITOOLS/Analytics+Middle+Tier)
* [Analytics Middle Tier Source Code](https://github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Analytics-Middle-Tier)

## Usage Guidelines

This repository provides a mechanism for community members to share their Views into the ODS with each other. Simply download the project and execute the SQL files that correlate to the Views you are interested in using. This is a great way to get started on your project without having to start from nothing.  We would appreciate any modifications to be contributed back to the project so others can leverage your work.

The Analytics Middle Tier is an open source project and these views are also available as open source. By default all contributions are available under the terms of the [Apache License, version 2.0](license). Please ensure that you maintain the appropriate licensing to contribute this work for others to reuse. If you wish to use terms other than the Apache 2.0 license then please include the license file with your views.


## Pre-requisites

Must have the following tools installed:


- [dotnet 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) (Runtime and SDK)

- [MSSQL 2019](https://www.microsoft.com/es-es/sql-server/sql-server-downloads) (must have an ODS DB installed)

- [PostgreSQL](https://www.postgresql.org/download/) (must have an ODS DB installed)

## Configuration

Choose the database you are interested in from the Installer.psm1 file in the option field.

- `Installer.ps1`

## Installation

For the installation of Analytics Middle Tier - Contributions, it can be installed by going to the installer folder and run.

- `Installer.ps1`
  
It will start the installation process for **MSSQL** & **PostgreSQL**, once it is ready the following message will appear on the screen saying:

`CEDS Views Installed.`

## Contribution Guidelines

The contribution process for sharing your work is as simple as:

1. Clone this repository with git.
1. Create a new branch named after your organization and use case
1. Commit your contribution to that branch
1. Create a pull request to merge your branch back on to the "main" branch in GitHub project.
1. Your pull request will be reviewed by a repository manager and will be merged upon approval

There is an example contribution provided in the "Contribution Template" folder located in the repository.

The contribution Format should include:

1. Your contribution should be placed inside a new folder named after the use case you are solving for and your organization (e.g. "Early warning System - Ed-Fi")
1. In the root of your new folder you should include:
    1. `readme.md`
    1. `mssql` folder (optional to include your MSSQL views)
    1. `postgres` folder (optional to include your postgres views)
1. The readme.md should include the following information:
    1. A brief description of the use case.
    1. List the supported ODS/AMT versions.
    1. Description of data assumptions.
    1. (optional) Your contact information if community members have questions. It is understood that you are under no obligation to provide support; however, providing contact information helps in creating a community of practice.

Several Notes on your contribution:

1.  You are not required to provide both MSSQL and postgres versions of your views.
1.  The SQL you submit should only create the Views needed for your use case.  Any other views, data manipulation, or database modification will NOT be accepted.
1. As long as your pull request follows these guidelines and appears to contribute something useful to the community, it will be approved and merged by the repository manager.

### Using Git

If you are new to Git, you might want to first explore one of these resources:

* [Git basics](https://www.atlassian.com/git) (from Atlassian)
* [GitHub for Atom](https://github.atom.io/) (from GitHub - use Git commands right from the MetaEd-IDE!)
* [Resources to learn Git](https://try.github.io/) (from GitHub)
* Code submitted to this repository must be signed with an encryption key, see [Signing Git commits](https://techdocs.ed-fi.org/display/ETKB/Signing+Git+Commits) on Tech Docs.

## License
Copyright &copy; Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, version 2.0](https://www.ed-fi.org/getting-started/license-ed-fi-technology/) license.
