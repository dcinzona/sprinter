public with sharing class AccountHierarchyCmpController {

    @AuraEnabled(cacheable=true)
    public static list<Account> findAllHierarchyAccounts(string recordId){
        list<Account> allAccountList=new List<Account>();
        Id ultimateAccountId;
        Set<Id> uniqueAccountIds = new Set<Id>();
        try{
            for(Account acc:[SELECT Id, ParentId, Ultimate_Account_Id__c from Account where Id=:recordId WITH SECURITY_ENFORCED]){
                ultimateAccountId = acc.ParentId == null ? acc.Id : acc.Ultimate_Account_Id__c;
            }
            
            if(string.isNotBlank(ultimateAccountId)){
                for(Account acc:[SELECT Id,(SELECT Id FROM ChildAccounts), (SELECT Id, AccountId, ContractNumber, Status FROM Contracts), Name, ParentId, Type, Parent.Name, Industry FROM Account 
                WHERE Ultimate_Account_Id__c=:ultimateAccountId OR Id =: ultimateAccountId WITH SECURITY_ENFORCED ORDER BY ParentId NULLS FIRST]){
                    allAccountList.add(acc);
                    uniqueAccountIds.add(acc.Id);
                }
            }

        } catch (Exception ex){
            System.debug('You dont have access to all Account fields \n' + ex.getMessage());
        }
        system.debug('***allAccountList size:'+allAccountList);
        return allAccountList;
    }

    // public static List<Contract> getContractsForAccounts(Set<Id>accountIds){
    //     List<Contract> contracts = new List<Contract>();
    //     try {
    //         contracts = [SELECT Id, AccountId FROM Contract WHERE AccountId IN :accountIds WITH SECURITY_ENFORCED];
    //     } catch (Exception ex){
    //         System.debug('No access to the appropriate objects \n' + ex.getMessage());
    //     }
    //     System.debug(contracts);
    //     return contracts;
    // }
}