public with sharing class AccountHierarchyHelper {

    public AccountHierarchyHelper() {
        
    }

    public void syncParentLookupWithFormula(List<Account> accounts){
        for(Account act : accounts){
            if(act.ParentId == null){
                act.Root_Record_Id__c = null;
                continue;
            }
            //in a tree
            if(String.isBlank(act.Root_Record_Id__c) || act.Root_Record_Id__c != act.Root_Record_Formula__c){
                if(String.isBlank(act.Root_Record_Formula__c)){
                    //Something is wrong
                    System.debug('Hierarchy issue with Account: ' + act.Id);
                } else {
                    act.Root_Record_Id__c = act.Root_Record_Formula__c;
                }
            }
        }
    }
}