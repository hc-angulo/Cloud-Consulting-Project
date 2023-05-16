public class TaskService {
    
   //|------Metodos--------|
    //Metodo para obtener tareas filtradas por usuario logueado *
    @AuraEnabled(cacheable=true)
    public static List<List<Project_Task__c>> getTasks(Id currentUser) {
        List<List<Project_Task__c>>tasksForEachProject = new List<List<Project_Task__c>>();
        List<Project_Task__c> tasksList = [ 
            SELECT Name, State__c, Start_Date__c, Register_Hours__c, Estimated_Hours__c, Project__r.Name, Project_Resource__r.Resource__c
            FROM Project_Task__c 
            WHERE Project_Resource__r.Resource__c =:currentUser 
            AND State__c != 'Completed' 
            ORDER BY Start_Date__c ASC
        ];
        System.debug('Mi lista de Total de Tareas:'+tasksList );
        System.debug('Longitud de Total de Tareas:'+tasksList.size());
        set<Id>taskIds=new set<Id>();
        Map<Id,List<Project_Task__c>>tasksForEachProjectMap =new Map<Id,List<Project_Task__c>>();
        for(Project_Task__c task:tasksList){
            taskIds.add(task.Project__r.Id);
            if(tasksForEachProjectMap.containsKey(task.Project__r.Id)){
                tasksForEachProjectMap.get(task.Project__r.Id).add(task);
            }else{
                tasksForEachProjectMap.put(task.Project__r.Id,new List<Project_Task__c>{task});
            }
        }
        for(Id task:taskIds){
            tasksForEachProject.add(tasksForEachProjectMap.get(task));
        }
        System.debug('Mi lista de Tareas por Proyecto:'+tasksForEachProject);
        return tasksForEachProject;
    }
    
    //Metodo para Cambiar de estado *
    
    @AuraEnabled
    public static Boolean updateTaskState(Id taskId, string state) {
        Boolean stateUpdated = false;
        Project_Task__c task = [SELECT Id,State__c FROM Project_Task__c WHERE Id =:taskId];
        if(task != null){
            task.State__c = state;
            update task;
            stateUpdated = true;
        }
        return stateUpdated;
    }
    
      //Metodo para registrar horas *
    @AuraEnabled
    public static Boolean registerHours(Id taskId, Integer hoursToAdd){
        Boolean hoursUpdated = false;
        Project_Task__c task = [SELECT Id,Register_Hours__c FROM Project_Task__c WHERE Id =:taskId];
        if(task != null){
            task.Register_Hours__c += hoursToAdd;
            update task;
            hoursUpdated = true;
        }
        return hoursUpdated;
    }
}