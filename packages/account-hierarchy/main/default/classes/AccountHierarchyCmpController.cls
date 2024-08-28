public with sharing class AccountHierarchyCmpController {

    @AuraEnabled(cacheable=true)
    public static list<Account> findAllHierarchyAccounts(string recordId){
        Id rootAccountId;
        List<Account> accounts = new List<Account>();
        
        //get root record id from current record
        if(Schema.sObjectType.Account.fields.Root_Record_Id__c.isAccessible()){
            
            Account currentAccount = [SELECT Id, ParentId, Root_Record_Id__c FROM Account WHERE Id=:recordId WITH USER_MODE LIMIT 1];
            rootAccountId = currentAccount.ParentId == null ? currentAccount.Id : currentAccount.Root_Record_Id__c;
            System.debug('Root account Id: ' + rootAccountId);
            
            if(Schema.SObjectType.Contract.isAccessible() && String.isNotBlank(rootAccountId)){
                accounts = [
                        SELECT Id,
                        (SELECT Id FROM ChildAccounts), 
                        (SELECT Id, AccountId, ContractNumber, Status FROM Contracts), 
                        Name, 
                        ParentId
                        FROM Account 
                        WHERE Root_Record_Id__c=:rootAccountId OR Id =: rootAccountId 
                        WITH USER_MODE
                        ORDER BY ParentId NULLS FIRST
                        ];
            }
        }
                
        return accounts;

    }
}