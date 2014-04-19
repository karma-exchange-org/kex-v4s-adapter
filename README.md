kex-v4s-adapter
===============

A managed package that syncs Karma Exchange's db with a Salesforce db using the Volunteers for Salesforce managed package

### Version Information

**Volunteers for Salesforce** 
  - app version 3.58
  - github (need to figure out what the exact commit timestamp of 3.5.8 is). For reference I've cloned commit  [f04f240e8141d0ac7ea4b9ce59f6293360d692ef](https://github.com/davidhabib/Volunteers-for-Salesforce/commit/f04f240e8141d0ac7ea4b9ce59f6293360d692ef) merged on 3/2/14.


### Eclipse Setup
* cd to where you want to install the project
* `git clone https://github.com/karma-exchange-org/kex-v4s-adapter.git`
* start eclipse kepler (assume you have force.com ide installed)
* eclipse create new workspace (in a different directory tree)
* eclipse "File"->"Import..." -> "General" -> "Existing project into workspace". Put the location where you cloned the project.
* eclipse "Project" -> "Properties" and search for Force.com
* put in your account information
