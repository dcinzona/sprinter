trigger AccountHierarchyTrigger on Account (before insert, before update) {
    if(Trigger.isBefore){
        AccountHierarchyHelper helper = new AccountHierarchyHelper();
        helper.syncParentLookupWithFormula(Trigger.new);
    }
}