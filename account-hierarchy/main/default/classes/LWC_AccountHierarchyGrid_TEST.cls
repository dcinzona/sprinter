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
private class LWC_AccountHierarchyGrid_TEST {

    @TestSetup
    static void makeData(){
        AccountHierarchy_TEST.assignPermSet();
        AccountHierarchy_TEST.createAccounts(200);
        AccountHierarchy_TEST.setParentLevels(6);
    }

    @isTest
    static void testController() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Account> roots = AccountHierarchy_TEST.getAllRootAccounts();
            List<Account> acts = AccountHierarchy_TEST.getAllChildAccounts();
            System.assert(acts.size()>3, 'Not enough child accounts');
            List<Account> hierarchy = AccountHierarchyCmpController.findAllHierarchyAccounts(roots[0].Id);
            System.debug(hierarchy.size());
            System.assert(hierarchy.size() == 6, 'Hierarchy size did not equal 6.  Size: ' + hierarchy.size());
            System.debug(hierarchy[0]);
        }
    }
    @isTest
    static void testNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');

        System.runAs(u) {
            AccountHierarchy_TEST.createAccounts(20);
            AccountHierarchy_TEST.setParentLevels(2);
            Test.startTest();
            List<Account> roots = AccountHierarchy_TEST.getAllRootAccounts();
            List<Account> acts = AccountHierarchy_TEST.getAllChildAccounts();
            System.assert(acts.size()>3, 'Not enough child accounts');
            List<Account> hierarchy = AccountHierarchyCmpController.findAllHierarchyAccounts(roots[0].Id);
            System.assert(hierarchy.size() == 0, 'Hierarchy should not have returned any records.  Size: ' + hierarchy.size());
            Test.stopTest();
        }
    }
}