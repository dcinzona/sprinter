public with sharing class AccountHierarchyHelper {

    public AccountHierarchyHelper() {
        
    }

    public void syncParentLookupWithFormula(List<Account> accounts){
        for(Account act : accounts){
            if(act.ParentId == null){
                act.Ultimate_Account_Id__c = null;
                continue;
            }
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
    }
}