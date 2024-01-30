# sprint-estimator

Contains rough code for a sprint estimator app.  This is a work in progress. Also contains an example LWC component for rendering out nested account structures and associated contracts.

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.


## Some commands:

- install the latest beta; `cci task run install_managed_beta --name sprint-estimator --org dev`
- create a beta: `cci flow run release_unlocked_beta`
- build test: `cci flow run build_unlocked_test_package`


## Account Hierarchy LWC setup

1. Install source from the account-hierarchy folder
2. Assign yourself the permission set `Account Hierarchy OWD FLS`
3. Add the LWC to your Account lightning record page
4. Update your account records to set the value of the root lookup `update [SELECT Id FROM Account WHERE ParentID != NULL]`
