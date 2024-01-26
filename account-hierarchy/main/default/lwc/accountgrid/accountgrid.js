import { LightningElement, wire, api } from "lwc";
import fetchAccounts from "@salesforce/apex/AccountHierarchyCmpController.findAllHierarchyAccounts";
const COLLS = [
    {
        type: "url",
        fieldName: "AccountURL",
        label: "Account Name",
        typeAttributes: {
            label: { fieldName: "accountName" },
            target: "_self",
        },
    },
    {
        type: "text",
        fieldName: "Industry",
        label: "Industry",
    },
    {
        type: "text",
        fieldName: "Type",
        label: "Type",
    },
];

export default class Accountgrid extends LightningElement {
    gridColumns = COLLS;
    gridData = [];
    roles = {};
    currentExpandedRows = [];
    @api recordId;
    @api objectApiName;

    @wire(fetchAccounts, { recordId: "$recordId" })
    AllAccountInfo({ error, data }) {
        if (error) {
            console.error("error loading accounts", error);
        } else if (data) {
            //console.log('*****dat from apex:'+JSON.stringify(data));
            console.log("**ObjectAPI Name:" + this.objectApiName + "***current account Id:" + this.recordId);
            var finaldata = [];
            var expandedRowInfo = [];
            console.log(data);
            for (var i = 0; i < data.length; i++) {
                if (data[i].ChildAccounts) {
                    expandedRowInfo.push(data[i].Id);
                    this.roles[data[i].Id] = {
                        accountName: data[i].Name,
                        Id: data[i].Id,
                        AccountURL: "/" + data[i].Id,
                        Type: data[i].Type ? data[i].Type : "",
                        Industry: data[i].Industry ? data[i].Industry : "",
                        _children: [],
                    };
                } else {
                    this.roles[data[i].Id] = {
                        accountName: data[i].Name,
                        Id: data[i].Id,
                        AccountURL: "/" + data[i].Id,
                        Type: data[i].Type ? data[i].Type : "",
                        Industry: data[i].Industry ? data[i].Industry : "",
                    };
                }
            }

            for (var i = 0; i < data.length; i++) {
                if (data[i].ParentId) {
                    if (this.roles[data[i].ParentId]) {
                        this.roles[data[i].ParentId]._children.push(this.roles[data[i].Id]);
                    }
                }
            }
            //console.log('***after adding childrens :'+JSON.stringify(this.roles));
            for (var i = 0; i < data.length; i++) {
                if (data[i].ParentId) {
                } else {
                    finaldata.push(this.roles[data[i].Id]);
                }
            }
            console.log("***finaldata :" + JSON.stringify(finaldata));
            this.gridData = finaldata;
            this.currentExpandedRows = expandedRowInfo;
            console.log("***currentExpandedRows 2:" + JSON.stringify(this.currentExpandedRows));
        }
    }
}
