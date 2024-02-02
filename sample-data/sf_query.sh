ROOT_REC_ID='00182000003X9fzAAC'
sf data query -q "SELECT Id, \
                    Root_Record_Id__c,\
                    (SELECT Id FROM ChildAccounts), \
                    (SELECT Id, AccountId, ContractNumber, Status FROM Contracts), \
                    Name, \
                    ParentId \
                    FROM Account \
                    WHERE Root_Record_Id__c = '$ROOT_REC_ID' \
                    OR Id = '$ROOT_REC_ID' \
                    WITH USER_MODE \
                    ORDER BY ParentId NULLS FIRST" --json
