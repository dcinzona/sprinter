({
    refreshView: function (component, event, helper) {
        //var recId = component.get("v.recordId");
        //console.log(recId);
        $A.get("e.force:refreshView").fire();
    }
})