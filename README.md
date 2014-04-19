kex-v4s-adapter
===============

A managed package that syncs Karma Exchange's db with a Salesforce db using the Volunteers for Salesforce managed package

### Version Information

* v4s app version 3.58
* v4s source treee: github (need to figure out what the exact commit timestamp of 3.5.8 is). For reference I've cloned commit  [f04f240e8141d0ac7ea4b9ce59f6293360d692ef](https://github.com/davidhabib/Volunteers-for-Salesforce/commit/f04f240e8141d0ac7ea4b9ce59f6293360d692ef) merged on 3/2/14.

### Test Salesforce DB setup

Minimum required for testingKarma Exchange and v4s integration:

* signup for a developer edition of Salesforce
* install the ["Volunteers for Salesforce"](https://appexchange.salesforce.com/listingDetail?listingId=a0N30000003JBggEAG) managed package. Note: there may be a delay between the time you signup for a db and you can install v4s (you may get a cryptic login error on app exchange)
* enable sites: "setup" -> "develop->sites". Enable sites and pick your own domain name. ([V4H installation guide section 4.1](http://djhconsulting.files.wordpress.com/2013/02/volunteers-for-salesforce-installation-configuration-guide-v32.pdf))
* create a site: "setup" -> "develop->sites" -> "new". For the label and name use "Volunteers". For the active site home page you can search for "under construction". Click "save". ([V4H installation guide section 4.2](http://djhconsulting.files.wordpress.com/2013/02/volunteers-for-salesforce-installation-configuration-guide-v32.pdf))
* enable public access to the rest api: "setup" -> "develop->sites" -> click on the site label "Volunteers" -> click the "Public Access Settings" button -> scroll to "Enabled Apex Class Access" -> click "edit" -> and add "KexRegistrationController" -> click "Save"
* activate the site: "setup" -> "develop->sites" -> click on activate ([V4H installation guide section 4.6](http://djhconsulting.files.wordpress.com/2013/02/volunteers-for-salesforce-installation-configuration-guide-v32.pdf))

To also test v4s sites go through sections 4.1 through 4.7 in the [V4H installation guide ](http://djhconsulting.files.wordpress.com/2013/02/volunteers-for-salesforce-installation-configuration-guide-v32.pdf).

### Eclipse Setup
* cd to where you want to install the project
* `git clone https://github.com/karma-exchange-org/kex-v4s-adapter.git`
* start eclipse kepler (assume you have force.com ide installed)
* eclipse create new workspace (in a different directory tree)
* eclipse "File"->"Import..." -> "General" -> "Existing project into workspace". Put the location where you cloned the project.
* eclipse "Project" -> "Properties" and search for Force.com
* put in your account information
