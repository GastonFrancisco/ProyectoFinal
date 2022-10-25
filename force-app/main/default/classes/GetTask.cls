public with sharing class GetTask {
    @AuraEnabled(cacheable = true)
    public static Map<String, List<ResourceTask__c>> getTaskByUser (){
        List<ResourceTask__c>tasksList = [SELECT Project__r.Name,  Name, Status__c, EstimatedHours__c, RegisterHours__c, StartDate__c
         FROM ResourceTask__c WHERE OwnerId =: UserInfo.getUserId() AND Status__c != 'Completed' ORDER BY  Status__c DESC, StartDate__c];

        Map<String, List<TaskProject__c>> taskListByProjectMap = new Map<String, List<TaskProject__c>>();

        for(TaskProject__c tsk: tasksList){
            if(taskListByProjectMap.containsKey(tsk.Project__r.Name)){
                taskListByProjectMap.get(tsk.Project__r.Name).add(tsk);
            } else{
                taskListByProjectMap.put(tsk.Project__r.Name, new List<ResourceTask__c>{tsk});
            }
        }
        return taskListByProjectMap;
    }
}
