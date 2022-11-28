public class ManagementOverSelectedResources {
    //--------Métodos para gestionar acciones sobre los recursos que se han insertado desde la interfaz-------//
    
    //Método que lista a los Recursos de un Proyecto que han sido seleccionados desde la interfaz.
    @AuraEnabled(cacheable=true)
    public static List<User> listOfSelectedResources(Id projectId){
        //system.debug('Id de Proyecto:'+projectId);
        List<Project_Resource__c>projectResources=[
            SELECT Required_Role__r.Project__r.Id,Resource__c From Project_Resource__c 
            WHERE Required_Role__r.Project__r.Id=:projectId
        ];
        set<Id>resourceIds = new set<Id>();
        for(Project_Resource__c projectResource:projectResources){
            resourceIds.add(projectResource.Resource__c);
        }
        List<User>users=[SELECT Name,Role__c From User WHERE Id IN:resourceIds ORDER BY Role__c DESC];
        return users;
    }
    //Método que, una vez que hemos seleccionado recursos desde la interfaz, borra, como recursos del proyecto, aquellos que seleccionemos.
    @AuraEnabled
    public static List<User> deleteResources(Id projectId,List<Map<String,Object>>selectedResources){
        //system.debug('Esto me llego para borrar:'+selectedResources);
        List<User> deletedUsers = new List<User>();
        if(selectedResources.size()>0){
            Boolean deleteSquadLead=false;
            Project__c project = [SELECT Id,Squad_Lead__c FROM Project__c WHERE Id=:projectId];
            set<Id>userIds = new set<Id>();
            for(Map<String,Object>resource:selectedResources){
                userIds.add((Id)resource.get('Id'));
                if(project.Squad_Lead__c==(Id)resource.get('Id')){
                    //system.debug('Este es el squadLead para borrar:'+project.Squad_Lead__c);
                    project.Squad_Lead__c=null;
                    //system.debug('campo squad lead borrado:'+project.Squad_Lead__c);
                    deleteSquadLead =true;
                }
            }
            if(deleteSquadLead){
                update project;
            }
            List<Project_Resource__c>resourceSelectedFromInterface = [
                SELECT Id, Resource__c 
                FROM Project_Resource__c 
                WHERE Resource__c In:userIds
            ];
            delete resourceSelectedFromInterface;
            set<Id> deletedUsersIds = new set<Id>();
            for(Project_Resource__c projectResource:resourceSelectedFromInterface){
                deletedUsersIds.add(projectResource.Resource__c);
            }
            deletedUsers =[
                SELECT Id, Role__c
                FROM User
                WHERE Id IN:deletedUsersIds
            ];
        }
        return deletedUsers;
    }
    //Método que, una vez se seleccione, permitirá asignar a un recurso com Squad Lead del Proyecto.
    @AuraEnabled
    public static User registerSquadLead(Id projectId,List<Map<String,Object>>selectedResource){
        Id userId = (Id)(selectedResource[0].get('Id'));
        //system.debug('Este es mi Squad Lead:'+userId);
        Project__c project = [SELECT Id,Squad_Lead__c FROM Project__c WHERE Id=:projectId];
        User squadLead =[SELECT Id,Name From User WHERE Id=:userId];
        project.Squad_Lead__c = userId;
        update project;
        return squadLead;
    }
}