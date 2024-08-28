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
        type: "url",
        fieldName: "ContractURL",
        label: "Contract Number",
        typeAttributes: {
            label: { fieldName: "ContractNumber" },
            target: "_self",
        },
        cellAttributes: {
            iconName: { fieldName: "iconName" },
            iconPosition: "left",
            iconAlternativeText: "Contract",
        },
    },
    {
        type: "text",
        fieldName: "ContractStatus",
        label: "Contract Status",
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
                if (data[i].ChildAccounts || data[i].Contracts) {
                    expandedRowInfo.push(data[i].Id);
                    this.roles[data[i].Id] = {
                        accountName: data[i].Name,
                        Id: data[i].Id,
                        AccountURL: "/" + data[i].Id,
                        _children: [],
                    };
                } else {
                    this.roles[data[i].Id] = {
                        accountName: data[i].Name,
                        Id: data[i].Id,
                        AccountURL: "/" + data[i].Id,
                    };
                }
                if (data[i].Contracts) {
                    for (var j = 0; j < data[i].Contracts.length; j++) {
                        this.roles[data[i].Id]._children.push({
                            accountName: data[i].Name,
                            Id: data[i].Contracts[j].Id,
                            ContractURL: "/" + data[i].Contracts[j].Id,
                            ContractNumber: data[i].Contracts[j].ContractNumber,
                            ContractStatus: data[i].Contracts[j].Status,
                            iconName: "standard:contract",
                        });
                    }
                }
            }

            for (var i = 0; i < data.length; i++) {
                if (data[i].ParentId) {
                    if (this.roles[data[i].ParentId]) {
                        this.roles[data[i].ParentId]._children.push(this.roles[data[i].Id]);
                    }
                }
            }

            for (var i = 0; i < data.length; i++) {
                if (data[i].ParentId) {
                    // child account record so don't do anything
                } else {
                    finaldata.push(this.roles[data[i].Id]);
                }
            }
            console.log(JSON.stringify(finaldata));
            this.gridData = finaldata;
            this.currentExpandedRows = expandedRowInfo;
            console.log("***currentExpandedRows 2:" + JSON.stringify(this.currentExpandedRows));
        }
    }
}
