public with sharing class ProjectResourceTriggerHelper {

    public static void BeforeInsert(List<Project_Resource__c> projectResourses){
        Map<Id, Project_Resource__c> newProjectResourceMap = new Map<Id, Project_Resource__c>();
        Id PLI = projectResourses[0].ProjectLineItem__c;
               
        for(Project_Resource__c pr :projectResourses){
            newProjectResourceMap.put(pr.Resource__c, pr);
        }
    
        ProjectLineItem__c project = [SELECT Project__r.StartDate__c, Project__r.EndDate__c FROM ProjectLineItem__c WHERE Id =: PLI];
        Date StartProject = project.Project__r.StartDate__c; 
        Date EndProject = project.Project__r.EndDate__c;
    
        List<Project_Resource__c> oldProjectResourcesList = [SELECT Id, StartDate__c, EndDate__c, Resource__c FROM Project_Resource__c WHERE Resource__c IN : newProjectResourceMap.keySet()];
    
        Map<Id, List<Project_Resource__c>> oldProjectResourceMap = new Map<Id, List<Project_Resource__c>>();
    
        for(Project_Resource__c pr :oldProjectResourcesList){
            if(oldProjectResourceMap.containsKey(pr.Resource__c)){
                oldProjectResourceMap.get(pr.Resource__c).add(pr);
            } else{
                oldProjectResourceMap.put(pr.Resource__c, new List<Project_Resource__c>{pr});
            }
        }    
    
        List<Project_Resource__c> readyForInsert = new List<Project_Resource__c>();
    
        for(Id key :newProjectResourceMap.keySet()){
    
            if(newProjectResourceMap.get(key).StartDate__c >= project.Project__r.StartDate__c && newProjectResourceMap.get(key).EndDate__c <= project.Project__r.EndDate__c){
    
            if(oldProjectResourceMap.containsKey(key)){
                
                for(Project_Resource__c pr :oldProjectResourceMap.get(key)){
    
                        if(newProjectResourceMap.get(key).StartDate__c < pr.StartDate__c && newProjectResourceMap.get(key).EndDate__c < pr.StartDate__c || newProjectResourceMap.get(key).StartDate__c > pr.EndDate__c && newProjectResourceMap.get(key).EndDate__c > pr.EndDate__c){
    
                            readyForInsert.add(newProjectResourceMap.get(key));
                        } else{
                            newProjectResourceMap.get(key).addError('The resource ' + newProjectResourceMap.get(key).Name + ' is allocated in another project on these Dates');
                        }
                    }
                } 
            }
            else{
                newProjectResourceMap.get(key).addError('The dates assigned dont match to the dates of the project');
               
            }
        }        
    } 
}