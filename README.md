kex-v4s-adapter
===============

A managed package that syncs Karma Exchange's db with a Salesforce db using the Volunteers for Salesforce managed package

### Version Information

* v4s app version 3.58
* v4s source treee: github (need to figure out what the exact commit timestamp of 3.5.8 is). For reference I've cloned commit  [f04f240e8141d0ac7ea4b9ce59f6293360d692ef](https://github.com/davidhabib/Volunteers-for-Salesforce/commit/f04f240e8141d0ac7ea4b9ce59f6293360d692ef) merged on 3/2/14.

### Test the Unmanaged Package

##### [1] Pre-installation steps

a. Install and setup the ["Volunteers for Salesforce"](https://appexchange.salesforce.com/listingDetail?listingId=a0N30000003JBggEAG) managed package. Make sure that the visualforce pages are functional.

b. Contact Karma Exchange Staff to get the following info:
* organization id
* secretkey
* serverurl (temporary until launch)

c. Provide the Karma Exchange Staff your salesforce db site url ("Build"->"Develop"->"Sites")

##### [2] Package installation

Use this URL to install the unmanaged package into your salesforce db:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti0000000H7KJ

Note: If you are installing into a sandbox organization use the following url instead:
http://test.salesforce.com/packaging/installPackage.apexp?p0=04ti0000000H7KJ

Default installation settings are fine. Nothing extra needs to be checked or unchecked.

##### [3] Enable public access to enable Karma Exchange to communicate to your db

*Note: All apis only execute if the org secret is validated.*

* "setup" -> "develop->sites"
* click on the site label "Volunteers"
* click the "Public Access Settings" button
* scroll to "Enabled Apex Class Access"
* click "edit"
* Add the following classes:
  * `KexRegistrationController`
  * `KexDebugController`
* Click "Save"

##### [4] Configure the Karma Exchange adminstrator settings for your organization

* "setup" -> "Develop->Custom Settings"
* Click "manage" next to "Karma Exchange Admin Settings"
* Click "new"
* Specify the organization id, secret key, and server url from step [1]
* Click save

##### [5] Add Karma Exchange to the remote sites

* "setup" -> "Administer->Security Controls->Remote Site Settings"
* click "new remote site"
* for the "remote site name" specify "KarmaExchange"
* for the "remote site url" specify the url from step [1]

##### [6] Define organizers / contacts for each shift. 

*Note: Please verify all contacts have email addreses.*

a. We recommend you set an organizer at the org level just in case there isn't one at a lower level.

* Select the "Karma Exchange" app
* Select the "Karma Exchange Settings" tab
* Click new
* Specify a default shift contact
* Click save

b. There are a couple other ways to specify a contact (will be explained in detail later).

* Campaign.Default Shift Contact
* Volunteer Job.Default Shift Contact
* Volunteer Shift.Volunteer Shift Contact (add to the volunteer shift page layout)

##### [7] Modify the shift layout to add the 'Sync with Karma Exchange' button

* Select the "Volunteers" app
* Go to an existing shift detail
* Click "Edit Layout"
* Select "Buttons"
* Drag the "Sync with Karma E..." button to your custom button row
* Click "Save"

##### [8] Test out the "Sync with Karma Exchange" button

a. Enable debug logs for your user and the volunteer guest user

* "Monitor -> Logs -> Debug Logs"
* Click "New" in the "Monitored Users"
* Select your user, click save
* Do the same for the "Volunteers Site Guest User"

b. Go to the shift. Click the `Sync with Karma Exchange` button. This will fire a future method which will eventually sync the job with Karma Exchange. You can monitor it in the debug logs.

c. Go to Karma Exchange to see if you see the job in the upcoming / past jobs for your organization.

d. Try registering and unregistering and see if the changes are reflected in salesforce.

##### [9] If Everything is working, try uploading all your upcoming shifts

* Select the "Karma Exchange" app
* Select the "Karma Exchange Admin" tab
* Click "Sync All Upcoming Volunteer Shifts"

##### [10] Enable automatic volunteer shift sync

* Select the "Karma Exchange" app
* Select the "Karma Exchange Admin" tab
* Click "Enable Automatic Volunteer Shift Sync"

Note: if you have a live db then you should always enable this to prevent the tracking table from growing to large. In a future version of the unmanaged package we will only upload entries to the tracking table if automatic shift sync is enabled.

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
