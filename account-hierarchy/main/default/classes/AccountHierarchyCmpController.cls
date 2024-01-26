public with sharing class AccountHierarchyCmpController {

    @AuraEnabled(cacheable=true)
    public static list<Account> findAllHierarchyAccounts(string recordId){
        list<Account> allAccountList=new List<Account>();
        Id ultimateAccountId;
        if (Schema.sObjectType.Account.isAccessible()) {
            for(Account acc:[select id,Ultimate_Account_Id__c from Account where Id=:recordId]){
                ultimateAccountId=acc.Ultimate_Account_Id__c;
            }
            if(string.isNotBlank(ultimateAccountId)){
                for(Account acc:[SELECT Id,(SELECT Id from ChildAccounts),Name,ParentId,Type,Parent.Name,Industry 
                FROM Account where Ultimate_Account_Id__c=:ultimateAccountId OR Id =: ultimateAccountId order by parentId NULLS FIRST]){
                    allAccountList.add(acc);
                }
            }
        }
        system.debug('***allAccountList size:'+allAccountList);
        return allAccountList;
    }
}