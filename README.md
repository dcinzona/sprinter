# Sprinter (WIP)

Contains rough code for a sprint estimator app and account hierarchy datagrid proof of concept.  This is a work in progress.

_Account Hierarchy LWC_
![Account Hierarchy](/docs/images/accounts-and-contracts.png)


## Development using CumulusCI

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.


## Additional CumulusCI commands:

- install the latest beta; `cci task run install_managed_beta --name sprint-estimator --org dev`
- create a beta: `cci flow run release_unlocked_beta`
- build test: `cci flow run build_unlocked_test_package`
- Import sfdx org: `cci org import <sfdx_alias> <cci_alias>`

... and more.  See the [CumulusCI documentation](https://cumulusci.readthedocs.io/en/latest/index.html) for more information.

## Account Hierarchy LWC setup

1. Install source from the account-hierarchy folder
2. Assign yourself the permission set `Account Hierarchy OWD FLS`
3. Add the LWC to your Account lightning record page
4. Update your account records to set the value of the root lookup `update [SELECT Id FROM Account WHERE ParentID != NULL]`


## General SF CLI Commands

More details can be found in the [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

#### Create a scratch org using the preview release API _(when applicable)_
```bash
sf org create scratch --definition-file orgs/dev.json --alias devscratch --set-default --target-dev-hub devhub -w 20 --release preview

sf org open -o devscratch
```

#### Install from source using API 60.0
```bash
sf project deploy start --source-dir account-hierarchy -c --ignore-conflicts -o devscratch -a 60.0
sf project deploy start --source-dir sprint-estimator -c --ignore-conflicts -o devscratch -a 60.0
```

#### Install using the sfdx-project.json API version 
```bash
sf project deploy start --source-dir account-hierarchy -c --ignore-conflicts -o devscratch
sf project deploy start --source-dir sprint-estimator -c --ignore-conflicts -o devscratch
```


## Package commands:

### Create a new unlocked package against your devhub
```bash
sf package create --name AccountHierarchyUnlocked --package-type Unlocked --path account-hierarchy --description "Account Hierarchy Unlocked Package" --no-namespace

sf package create --name SprintEstimatorUnlocked --package-type Unlocked --path sprint-estimator --description "Sprint Estimator Unlocked Package" --no-namespace
```

### Delete a package
```bash
sf package delete --package "Your Package Alias"
```

### Versioning
```bash
sf package version create --package AccountHierarchyUnlocked --installation-key password123 --target-dev-hub devhub
```

### Install a package

_Requires creating a package version first_
```bash
sf package install --package AccountHierarchyUnlocked -k password123 -o devscratch
```

## Data Manipulation

### Generate fake data with CumulusCI
This is the preferred way to generate data for testing.  It uses the Snowfakery library to generate data from a recipe file.
More information here: https://snowfakery.readthedocs.io/en/stable/index.html#advanced-features

```bash
cci task run snowfakery --recipe datasets/account-contract.recipe.yml --org devscratch 
```


### Seed Account / Contract data with SF CLI (deprecated)
Documentation: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_test_data_example.htm

## Scanning for common files across packages
You can use the python script `project-scan.py` to scan for common files across packages.  This is useful for identifying common files that can be moved to a shared package.

```bash
sh project-scan.sh
```