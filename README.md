kex-v4s-adapter
===============

A managed package that syncs Karma Exchange's db with a Salesforce db using the Volunteers for Salesforce managed package

### Version Information

* v4s app version 3.58
* v4s source treee: github (need to figure out what the exact commit timestamp of 3.5.8 is). For reference I've cloned commit  [f04f240e8141d0ac7ea4b9ce59f6293360d692ef](https://github.com/davidhabib/Volunteers-for-Salesforce/commit/f04f240e8141d0ac7ea4b9ce59f6293360d692ef) merged on 3/2/14.

### Test the Managed Beta Package

##### [1] Pre-installation steps

a. Install and setup the ["Volunteers for Salesforce"](https://appexchange.salesforce.com/listingDetail?listingId=a0N30000003JBggEAG) (V4S) managed package. Make sure that the V4S visualforce pages are working.

b. Contact Karma Exchange staff to get the following info:
* organization id
* secretkey
* serverurl (temporary until launch)

c. Provide the Karma Exchange staff your salesforce db site url ("Build"->"Develop"->"Sites")

##### [2] Package installation

Use this URL to install the unmanaged package into your salesforce db:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04to0000000DnaA

Note: If you are installing into a sandbox organization use the following url instead:
http://test.salesforce.com/packaging/installPackage.apexp?p0=04to0000000DnaA

Default installation settings are fine. Nothing extra needs to be checked or unchecked.

##### [3] Enable public access to enable Karma Exchange to communicate to your db

*Note: All apis only execute if the org secret is validated.*

* "setup" -> "develop->sites"
* click on the site label "Volunteers"
* click the "Public Access Settings" button
* scroll to "Enabled Apex Class Access"
* click "edit"
* Add the following classes:
  * `Karma.KexRegistrationController`
  * `Karma.KexDebugController`
* Click "Save"

##### [4] Add Karma Exchange to the remote sites

* "setup" -> "Administer->Security Controls->Remote Site Settings"
* click "new remote site"
* for the "remote site name" specify "KarmaExchange"
* for the "remote site url" specify the url from step [1]

TODO(avaliani): automate this step

##### [5] Configure the Karma Exchange adminstrator settings for your organization

* Select the "Karma Exchange" app
* Select the "Karma Exchange Settings" tab
* Click new
* Specify the organization id, secret key, and server url from step [1]
* (recommended) Specify a default shift contact / default organizer for your organization
* Click save


##### [6] (optional) Define organizers / contacts for each shift. 

*Note: Please verify all contacts have email addreses.*

You can do this through the following fields:

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

Note: if you have a live db then you should always enable this to prevent the tracking table from growing too large. In a future version of the unmanaged package we will only upload entries to the tracking table if automatic shift sync is enabled.

##### [11] Display a map of the Volunteer Job location

To help prevent geo-coding errors for Volunteer Jobs, Karma Exchange includes a visual force page to display the job location.

* Go to the detail page of a Volunteer Job
* Click "Edit Layout"
* Select "Visualforce Pages"
* Drag the "Volunteer Job Map" VF page to wherever you'd like to see it. We recommend putting it below the "Location information" field.
* Double click on the newly dragged item.
* Set the height to 300px.
* Click "OK"
* Click "Save"

##### [12] Summary of new fields

* Sponsoring Org Fields
  * `Campaign.Sponsoring Org for Volunteer Jobs` - specifies the organization that is actually sponsoring / running the volunteer jobs under this campaign.
  * `Account.Karma Exchange Org Id` - specifies the org id for the sponsoring org. Only use this for orgs that are registered with Karma Exchange. If this is not specified a Karma Exchange org is automatically generated for the sponsoring org based on `Account.Name`. In this case the sponsoring org will show up in Karma Exchange with the logo of the salesforce db root org - specified in the `Karma Exchange Admin Settings` custom settings. If you modify `Account.Name` you must contact the Karma Exchange staff to ensure that all events consolidate under one org. 
  * `Account.Karma Exchange Org Secret Key` - specifies the org secret key for the sponsoring org. This must be specified if Account."Karma Exchange Org Id" is non-null. This prevents one org from accidentally impersonating another org.
* External Registration Fields
  * `Volunteer Job.External Registration Url` - URL of site to signup to volunteer for the job. If this field is specified, volunteer registration will not be managed by Karma Exchange.
  * `Volunteer Job.External Registration Details` - Details (phone number, email, etc.) on how to register for the volunteer job. If this field is specified, volunteer registration will not be managed by Karma Exchange.
* `Volunteer Job.Location Coordinates` - allows users to specify the exact location of the Volunteer Job. If specified these gps coordinates are used instead of the result from geocoding the Volunteer Job location address fields.

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
