public with sharing class GetUsers {
    @InvocableMethod(label='Get Users' description='Returns a list of available users' category='User')
    public static List<List<User>> getUsersByRole (List<ProjectLineItem__c> projectLine){
        Boolean assign = true;
        
        ProjectLineItem__c projectLineItem;
        if(projectLine.size() == 1){
            for(ProjectLineItem__c pli: projectLine){
                projectLineItem = pli;
            }
        }

        Project__c project = [SELECT Id, Name, StartDate__c, EndDate__c, Amount__c FROM Project__c WHERE Id =: projectLineItem.Project__c];
       
        Date startDate = project.StartDate__c;
        Date endDate = project.EndDate__c;
        
        
        List<User> usersListByRole = [SELECT Id, Name, Role__c, Rateph__c, ( SELECT StartDate__c, EndDate__c, ProjectLineItem__r.Project__c FROM Project_Resources__r WHERE  (StartDate__c >=:startDate AND StartDate__c <=: endDate) OR (EndDate__c >=:startDate AND EndDate__c <=: endDate )) FROM User WHERE Role__c =: projectLineItem.Role__c];

        
        List<List<User>> a = new List<List<User>>();
        List<User> availableUsers = new List<User>();
        
        for(User user : usersListByRole){
            if(user.Project_Resources__r.isEmpty()){
                availableUsers.add(user);
            }
        }
        a.add(availableUsers);
        return a;
    }
}