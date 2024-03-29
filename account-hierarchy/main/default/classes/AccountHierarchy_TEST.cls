/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class AccountHierarchy_TEST {


    @TestSetup
    static void makeData(){
        assignPermSet();
        createAccounts(200);
    }


    @isTest
    static void testPermissions() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            System.assert(Schema.sObjectType.Account.fields.Root_Record_Id__c.isAccessible(), 'Root_Record_Id__c is not accessible');
            System.assert(Schema.sObjectType.Account.fields.Root_Record_Formula__c.isAccessible(), 'Root_Record_Formula__c is not accessible');
            System.assert(Schema.sObjectType.Contract.isAccessible(), 'Contract is not accessible');
        }
    
    }

    @isTest
    static void testAccountCreation() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            for(Account act : getAccounts()){
                if(act.ParentId != null){
                    System.assert(act.ParentId == null && String.isBlank(act.Root_Record_Formula__c), 'Parent was ' + act.ParentId + ' and formula was ' + act.Root_Record_Formula__c);
                }
            }
        }
    }

    @isTest
    static void testAccountParentLevels() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account root = AccountHierarchy_TEST.setParentLevels(MAX_DEPTH);
            Set<Id> rootIds = new Set<Id>();
            for(Account rootAct : getAllRootAccounts()){
                rootIds.add(rootAct.Id);
            }
            List<Account> childAccounts = getAllChildAccounts();
            for(Account child :childAccounts){
                System.Assert(String.isNotBlank(child.Root_Record_Id__c), 'Child Account has a parent but root was blank');
                System.Assert(child.Root_Record_Id__c == child.Root_Record_Formula__c, 'Mismatch Root parent ('+child.Root_Record_Id__c+') and formula ('+child.Root_Record_Formula__c+')');
            }
    
            Account child = childAccounts[childAccounts.size() - 1];
    
            System.Assert(child.Root_Record_Id__c == root.Id, 'Child Account has a parent but root ('+ child.Root_Record_Id__c+') was not correct. Should have been ' + root.Id);
        }
        
    }


    /*******************
     * UTILITY METHODS *
     *******************/

    static Integer MAX_DEPTH = 6;

    public static List<Account> createAccounts(Integer numberOfAccounts){
        List<Account> accountsList = new List<Account>();
        for(Integer i = 0; i< numberOfAccounts; i++){
            Account act = new Account(Name='test account '+ i);
            accountsList.add(act);
        }
        insert accountsList;

        return accountsList;
    }

    public static Account setParentLevels(Integer levels){
        Account root = null;
        List<Account> acts = getAccounts();
        Integer curLevel = 0;
        for(Integer i = 0; i < acts.size(); i++){
            // don't set parent for first account record.
            if(i==0){
                root = acts[i];
                continue;
            }
            Account cur = acts[i];
            if(curLevel >= levels-1){
                // set new root
                root = cur;
                curLevel = 0;
                cur.ParentId = null;
                // don't set a parent      
                continue;
            }
            cur.ParentId = curLevel == 0 ? root.Id : acts[i-1].Id;
            curLevel++;
        }
        update acts;

        return root;
    }

    public static List<Account> getAccounts(){
        return [SELECT Id, ParentId, Root_Record_Formula__c, Root_Record_Id__c FROM Account];
    }

    public static List<Account> getAllRootAccounts(){
        return [SELECT Id FROM Account WHERE ParentId = null];
    }

    public static List<Account> getAllChildAccounts(){
        return [SELECT Id, ParentId, Root_Record_Formula__c, Root_Record_Id__c FROM Account WHERE ParentId != null];
    }


    public static void assignPermSet(){

        try {        
            System.runAs(new User(Id = Userinfo.getUserId())) {
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Hierarchy_OWD_FLS' LIMIT 1];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = Userinfo.getUserId();
                psa.PermissionSetId = ps.Id;
                insert psa;
            }
        } catch (Exception ex){
            System.debug(ex.getMessage());
        }
        
    }



}