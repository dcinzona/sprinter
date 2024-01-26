public with sharing class AccountHierarchyHelper {

    public static Map<Id,Boolean> hasRunForIds = new Map<Id,Boolean>();
    public AccountHierarchyHelper() {
        AccountHierarchyHelper.hasRunForIds.clear();
    }
    public void syncParentLookupWithFormula(List<Account> accounts){
        for(Account act : accounts){
            if(act.ParentId != null){
                //in a tree
                if(String.isBlank(act.Ultimate_Account_Id__c) || act.Ultimate_Account_Id__c != act.Ultimate_Parent_Formula__c){
                    if(String.isBlank(act.Ultimate_Parent_Formula__c)){
                        //Something is wrong
                        System.debug('Hierarchy issue with Account: ' + act.Id);
                    } else {
                        act.Ultimate_Account_Id__c = act.Ultimate_Parent_Formula__c;
                    }
                }
            }
            else {
                if(act.Ultimate_Account_Id__c != null){
                    //no parent, so ultimate account should be null
                    act.Ultimate_Account_Id__c = null;
                }
            }
        }
    }
}