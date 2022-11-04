@isTest
public with sharing class ProjectResourceTriggerTest {

    private static String role ='Developer';
    private static User dev =[SELECT Id, LastName, UserRole.Name FROM User WHERE UserRole.Name = 'Developer' LIMIT 1 ];

    private static Opportunity newOpp (Id pm){
        Opportunity newOpp = new Opportunity (
            Name= 'Opp Test',
            CloseDate= System.today(),
            StartDate__c= System.today(),
            EndDate__c = System.today().addDays(30),
            ProjectManager__c= pm,
            StageName= 'Negotiation/Review'
        );
        return newOpp;
    }

    private static OpportunityLineItem__c newOppLineItem(Id oppId, String role){

        OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c(
            Name = role,
            Opportunity__c = oppId,
            Role__c =role,
            Quantity__c = 24,
            Amount__c = 500
        );
        return oppLineItem;
    }

    private static Project_Resource__c newPR (Id PLiID, Date startDate ,Date endDate, Id resourceId){
        Project_Resource__c PR = new Project_Resource__c(
            Name = '',
            ProjectLineItem__c = PLiId,
            StartDate__c = startDate,
            EndDate__c = endDate,
            Resource__c = resourceId
            );
        return PR;
    }

    @isTest

    private static void testProjectResourceTrigger(){
        //SET UP 
        User pm = [SELECT Id, Name FROM User WHERE Role__c = 'ProjectManager' LIMIT 1];

        Opportunity opp = newOpp(pm.Id);
        insert opp;
        Id oppId = opp.Id;

        OpportunityLineItem__c oppLI = newOppLineItem(oppId, role);       
        insert oppLI;

        opp.StageName = 'Closed Won';
        update opp;
		
        //TEST POSITIVE
        Project__c project =[SELECT Id, Name, Opportunity__c FROM Project__c ];  

        ProjectLineItem__c PLI =[SELECT Id, Project__c FROM ProjectLineItem__c WHERE Project__c =: project.Id];
        
        Project_Resource__c PR1 = newPR(PLI.Id, System.today(), System.today().addDays(10),dev.Id);
        insert PR1;
           
        Project_Resource__c PR2 = newPR(PLI.Id, System.today().addDays(11), System.today().addDays(20),dev.Id);
        insert PR2;
		
        //TEST NEGATIVE
        Project_Resource__c PR3 = newPR(PLI.Id, System.today(), System.today().addMonths(2),dev.Id);
        
        try {
            insert PR3;
        } catch (DmlException e) {
            //Assert Error Message
            System.assert( e.getMessage().contains('Insert failed. First exception on ' +
                'row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' +
                'The dates assigned do not correspond to the dates of the project: []'), 
                e.getMessage() );

                //Assert Status Code
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
        } 

        Project_Resource__c PR4 = newPR(PLI.Id, System.today(), System.today().addDays(10),dev.Id);

        try {
            insert PR4;
        } catch (DmlException e) {
            //Assert Error Message
            System.assert( e.getMessage().contains('Insert failed. First exception on ' +
                'row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' +
                'The resource '+ dev.LastName +' is not available on these Dates: []'), 
                e.getMessage() );

                //Assert Status Code
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
        } 


        List<Project_Resource__c> ProjectResourceCreated = [SELECT Id, Name FROM Project_Resource__c];
		
        //ASSERT POSITIVE
        System.assertEquals(2, ProjectResourceCreated.size());

    }
}