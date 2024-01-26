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
        List<Account> accounts = new List<Account>();
        for(integer i = 0; i < 20; i++){
            accounts.add(new Account(Name='test account '+ i));
        }
        insert accounts;
    }

    public static List<Account> getAccounts(){
        return [SELECT Id, ParentId, Ultimate_Parent_Formula__c, Ultimate_Account_Id__c FROM Account];
    }
   public static List<Account> getAllChildAccounts(){
        return [SELECT Id, ParentId, Ultimate_Parent_Formula__c, Ultimate_Account_Id__c FROM Account WHERE ParentId != null];
    }

    @isTest
    static void testAccountCreation() {
        // TO DO: implement unit test
        for(Account act : getAccounts()){
            if(act.ParentId != null){
                System.assert(act.ParentId == null && String.isBlank(act.Ultimate_Parent_Formula__c), 'Parent was ' + act.ParentId + ' and formula was ' + act.Ultimate_Parent_Formula__c);
            }
        }
    }

    @isTest
    static void testAccountParentLevel1() {
        // TO DO: implement unit test
        Account root = setParentLevels(1);
        List<Account> childAccounts = getAllChildAccounts();
        for(Account child: childAccounts){
            System.assert(child.ParentId == root.Id);
            System.assert(child.Ultimate_Account_Id__c == root.Id);
        }
    }

    public static Account setParentLevels(Integer levels){
        Account root = null;
        if(Test.isRunningTest()){
            Account prev = null;
            List<Account> acts = getAccounts();
            System.Assert(levels <= acts.size(), 'Not enough accounts to process ' + levels + ' levels. Total Accounts: ' + acts.size());
            for(Integer i = 0; i < levels; i++){
                Account cur = acts[i];
                if(prev == null){
                    root = acts[i];
                    prev = root;
                } else {
                    cur.ParentId = prev.Id;
                    prev = cur;
                }
            }
            update acts;
        }
        return root;
    }

    @isTest
    static void testAccountParentLevel6() {
        // TO DO: implement unit test
        Account root = AccountHierarchy_TEST.setParentLevels(6);
        List<Account> childAccounts = getAllChildAccounts();
        for(Account child :childAccounts){
            System.Assert(String.isNotBlank(child.Ultimate_Account_Id__c), 'Child Account has a parent but root was blank');
            System.Assert(child.Ultimate_Account_Id__c == root.Id, 'Child Account has a parent but root ('+ child.Ultimate_Account_Id__c+') was not correct. Should have been ' + root.Id);
            System.Assert(child.Ultimate_Account_Id__c == child.Ultimate_Parent_Formula__c, 'Mismatch ultimate parent ('+child.Ultimate_Account_Id__c+') and formula ('+child.Ultimate_Parent_Formula__c+')');
        }
    }
}