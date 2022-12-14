public with sharing class GetRolesWithUsers {
    @AuraEnabled
    public static void metodoX ( Id projectId , string resourcesMap  ) {
        system.debug(resourcesMap + ' ' + projectId );
        Map<Id,list<date>> resourcebymap = (Map<Id, list<date>>)JSON.deserializeStrict( resourcesMap, Map<Id, list<date>>.class);
        Project__c proyect =[SELECT name,(SELECT Role__c,Id FROM ProjecstLineItem__r WHERE Project__c =: projectId) FROM Project__c WHERE Id =: projectId];
        
        map<string,id> RolbyPliId =new map<string,id>();
        for(ProjectLineItem__c PLI : proyect.ProjecstLineItem__r){
            RolbyPliId.put(PLI.Role__c, PLI.Id);
        }
 
    
     list<user> ListResource=[SELECT Role__c,Name FROM user WHERE Id in: resourcebymap.keySet()];
 
         list <Project_Resource__c> listProyectResource = new list <Project_Resource__c>();
 
         for (user resource : ListResource){
             
             listProyectResource.add(new Project_Resource__c (
                 Resource__c = resource.Id,
                 name = resource.name,
                 projectLineItem__c= RolbyPliId.get(resource.role__c),
                 StartDate__c=resourcebymap.get(resource.Id)[0],
                 endDate__c=resourcebymap.get(resource.Id)[1],
                 role__c=resource.role__c
             ));
         }
         system.debug('list ' + listProyectResource );
         insert listProyectResource;
         
    }

    public class ProjectWrapper{
        @AuraEnabled
        public List<ProjectLineItem__c> roles = new List<ProjectLineItem__c>(); 

        @AuraEnabled
        public Map<String, List<User>> resources = new Map<String, List<User>>();
        
        public ProjectWrapper(List<ProjectLineItem__c> roles, Map<String, List<User>> resources){
            this.roles = roles;
            this.resources = resources;
        }
    }

    @AuraEnabled(cacheable=true)
    public static ProjectWrapper getProjectWrapper(Id projectId){
        ProjectWrapper wrapper = new ProjectWrapper(getProjectRoles(projectId), getResourcesByRole(projectId));

        return wrapper;
    }
    
    public static List<ProjectLineItem__c> getProjectRoles(Id projectId){
        List<ProjectLineItem__c> projectLineItem = [SELECT Id, Role__c, CoveredHours__c FROM ProjectLineItem__c WHERE Project__c =: projectId];

        return projectLineItem;
    }

    public static Map<String, List<User>> getResourcesByRole(Id projectId){
        List<ProjectLineItem__c> projectLineItem = getProjectRoles(projectId);

        Set<String> roles = new Set<String>();
        for(ProjectLineItem__c pli: projectLineItem){
            roles.add(pli.Role__c);
        }

        Project__c project = [SELECT Id, Name, StartDate__c, EndDate__c FROM Project__c WHERE Id =: projectId];
       
        Date startDate = project.StartDate__c;
        Date endDate = project.EndDate__c;

        List<User> usersListByRole = [SELECT Id, Name, Role__c, Rateph__c, (SELECT StartDate__c, EndDate__c, ProjectLineItem__r.Project__c FROM Project_Resources__r WHERE (StartDate__c >=:startDate AND StartDate__c <=: endDate) OR (EndDate__c >=:startDate AND EndDate__c <=: endDate ) ORDER BY StartDate__c ASC) FROM User WHERE Role__c IN: roles];

        Map<String, List<User>> resourcesByRole = new Map<String, List<User>>();
        Map<Id, String> roleByUser = new Map<Id, String>();

        for(User resource: usersListByRole){
            if(resource.Project_Resources__r.size() == 0){
                if(resourcesByRole.containsKey(resource.Role__c)){
                    resourcesByRole.get(resource.Role__c).add(resource);
                } else{
                    resourcesByRole.put(resource.Role__c, new List<User>{resource});
                }
            }
            if(resource.Project_Resources__r.size() == 1){
                if((startDate < resource.Project_Resources__r[0].StartDate__c && startDate.daysBetween(resource.Project_Resources__r[0].StartDate__c) >= 1) || (resource.Project_Resources__r[0].EndDate__c < endDate && resource.Project_Resources__r[0].EndDate__c.daysBetween(endDate) >= 1)){
                    if(!roleByUser.containsKey(resource.Id)){
                        roleByUser.put(resource.Id, resource.Role__c);
                        if(resourcesByRole.containsKey(resource.Role__c)){
                            resourcesByRole.get(resource.Role__c).add(resource);
                        } else{
                            resourcesByRole.put(resource.Role__c, new List<User>{resource});
                        }
                    }
                }
            } else{
                for(Project_Resource__c proResource: resource.Project_Resources__r){

                    Integer currentIterationIndex = resource.Project_Resources__r.indexOf(proResource);

                    Date iterationStartDate = proResource.StartDate__c;
                    Date iterationEndDate = proResource.EndDate__c;

                    if(currentIterationIndex == 0 && (startDate < iterationStartDate && startDate.daysBetween(iterationStartDate) > 1)){
                        if(getWeekDays(startDate, iterationStartDate) >= 1){
                            if(!roleByUser.containsKey(resource.Id)){
                                roleByUser.put(resource.Id, resource.Role__c);
                                if(resourcesByRole.containsKey(resource.Role__c)){
                                    resourcesByRole.get(resource.Role__c).add(resource);
                                } else{
                                    resourcesByRole.put(resource.Role__c, new List<User>{resource});
                                }
                            }
                        }
                    } else if(currentIterationIndex != 0 && (currentIterationIndex + 1) != resource.Project_Resources__r.size()){
                        Integer previousIterationIndex = resource.Project_Resources__r.indexOf(proResource);
                        previousIterationIndex -= 1;

                        Date previousIterationEndDate = resource.Project_Resources__r[previousIterationIndex].EndDate__c;

                        if((previousIterationEndDate < iterationStartDate) && previousIterationEndDate.daysBetween(iterationStartDate) > 1){
                            if((getWeekDays(previousIterationEndDate, iterationStartDate) - 1) >= 1){
                                if(!roleByUser.containsKey(resource.Id)){
                                    roleByUser.put(resource.Id, resource.Role__c);
                                    if(resourcesByRole.containsKey(resource.Role__c)){
                                        resourcesByRole.get(resource.Role__c).add(resource);
                                    } else{
                                        resourcesByRole.put(resource.Role__c, new List<User>{resource});
                                    }
                                }
                            }
                        }
                    } else if((currentIterationIndex + 1) == resource.Project_Resources__r.size()){
                        Integer previousIterationIndex = resource.Project_Resources__r.indexOf(proResource);
                        previousIterationIndex -= 1;

                        Date previousIterationEndDate = resource.Project_Resources__r[previousIterationIndex].EndDate__c;

                        if((previousIterationEndDate < iterationStartDate && previousIterationEndDate.daysBetween(iterationStartDate) > 1) || (iterationEndDate < endDate &&iterationEndDate.daysBetween(endDate) > 1)){
                            if((getWeekDays(previousIterationEndDate, iterationStartDate) - 1) >= 1 ||getWeekDays(iterationEndDate, endDate) >= 1){
                                if(!roleByUser.containsKey(resource.Id)){
                                    roleByUser.put(resource.Id, resource.Role__c);
                                    if(resourcesByRole.containsKey(resource.Role__c)){
                                        resourcesByRole.get(resource.Role__c).add(resource);
                                    } else{
                                        resourcesByRole.put(resource.Role__c, new List<User>{resource});
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return resourcesByRole;
    }

    public static Integer getWeekDays(Date startDate, Date iterationDate){
        Date initStartDate = startDate;
        DateTime formattedInitDate;
        String dayOfWeek;
        Integer realDaysBetween = 0;
        for(Integer i = 0; i < startDate.daysBetween(iterationDate); i++){
            initStartDate = initStartDate.addDays(1);
            formattedInitDate = (DateTime)initStartDate;
            dayOfWeek = formattedInitDate.format('E');
            if(dayOfWeek != 'Sat' && dayOfWeek != 'Sun'){
                realDaysBetween +=1;
            }
        }
        return realDaysBetween - 1;
    }
}