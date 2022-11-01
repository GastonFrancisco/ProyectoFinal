public with sharing class GetUsers {
    @InvocableMethod(label='Get Users' description='Returns a list of available users' category='User')
    public static List<List<User>> getUsersByRole (List<ProjectLineItem__c> projectLine){
        Boolean assign = true;
        //Buscamos en la DB el proyecto actual
        ProjectLineItem__c projectLineItem;
        if(projectLine.size() == 1){
            for(ProjectLineItem__c pli: projectLine){
                projectLineItem = pli;
            }
        }

        Project__c project = [SELECT Id, Name, StartDate__c, EndDate__c, Amount__c FROM Project__c WHERE Id =: projectLineItem.Project__c];
       
        Date startDate = project.StartDate__c;
        Date endDate = project.EndDate__c;
        
        //Buscamos en la DB todos los usuarios con un mismo rol disponibles para el proyecto
        List<User> usersListByRole = [SELECT Id, Name, Role__c, Rateph__c, ( SELECT StartDate__c, EndDate__c, ProjectLineItem__r.Project__c FROM Project_Resources__r WHERE  (StartDate__c >=:startDate AND StartDate__c <=: endDate) OR (EndDate__c >=:startDate AND EndDate__c <=: endDate )) FROM User WHERE Role__c =: projectLineItem.Role__c];

        //Creamos una List para popular los usuarios disponibles para el proyecto
        List<List<User>> a = new List<List<User>>();
        List<User> availableUsers = new List<User>();
        //Filtramos los usuarios y populamos la lista
        for(User user : usersListByRole){
            if(user.Project_Resources__r.isEmpty()){
                availableUsers.add(user);
            } /*else {
                for(Project_Resource__c pr : user.Project_Resources__r){
                    if(pr.ProjectLineItem__r.Project__c != project.Id){
                        assign = false;
                    }
                }
                if(assign){
                    availableUsers.add(user);
                }
            }*/
        }
        a.add(availableUsers);
        return a;
    }
}