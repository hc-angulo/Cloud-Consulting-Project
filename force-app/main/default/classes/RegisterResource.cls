public class RegisterResource {
    //------------------Método para ser llamado desde el Trigger "Register Resource"-------------------//
    public static void onBeforeInsert(List<Project_Resource__c>projectResourceList){
        //Los sets a continuación recogerán información de los campos Resource__c, de tipo Lookup(User), y Required_Role__c, de tipo Master-Detail(Required_Role__c), de aquellos registros que disparen el Trigger en el evento "Before Insert".
        set<Id>UserIds = new set<Id>();
        set<Id>requiredRoleIds = new set<Id>();
        for(Project_Resource__c projectResource:projectResourceList){
            UserIds.add(projectResource.Resource__c);
            requiredRoleIds.add(projectResource.Required_Role__c);
        }
        //La lista a continuación es de los Usuarios que son recursos en los registros del Objeto "Project_Resource__c" que disparan el Trigger. Al hacer query en la base de datos, necesitamos la información del Rol del Usuario y la lista de los registros, en el objeto "Project_Resource__c",  relacionados a cada uno de estos.
        List<User>users=[
            SELECT Id,Role__c,(SELECT Id,Start_Date__c,End_Date__c FROM Project_Resources__r WHERE Required_Role__r.Project__r.Stage__c!='Completed' ORDER BY Start_Date__c ASC) 
            FROM User 
            WHERE Id IN:UserIds
        ];
        Map<Id,User>usersMap = new Map<Id,User>(users);
        //Información que nos permitirá tener acceso a datos de fecha del proyecto y roles necesitados en éste.
        List<RequiredRole__c>requiredRolesListDb=[
            SELECT Id, Role__c,Project__r.Start_Date__c,Project__r.End_Date__c 
            FROM RequiredRole__c 
            WHERE Id IN:requiredRoleIds
        ];
        Map<Id,RequiredRole__c>requiredRolesMapDb=new Map<Id,RequiredRole__c>(requiredRolesListDb);
        for(Project_Resource__c projectResource:projectResourceList){
            RequiredRole__c requiredRoleFromMap=requiredRolesMapDb.get(projectResource.Required_Role__c);
            String requiredRole = requiredRoleFromMap.Role__c;
            String resourceRole = usersMap.get(projectResource.Resource__c).Role__c;
            Date projectStartDate = requiredRoleFromMap.Project__r.Start_Date__c;
            Date projectEndDate = requiredRoleFromMap.Project__r.End_Date__c;
            Date endDate = projectResource.End_Date__c;
            Date startDate = projectResource.Start_Date__c;
            if(projectStartDate<=startDate && endDate<=projectEndDate && requiredRole==resourceRole){
                List<Project_Resource__c> projectPerUserList=usersMap.get(projectResource.Resource__c).Project_Resources__r;
                Integer sizeList =(Integer)projectPerUserList.size();
                Integer counter=0;
                for(Project_Resource__c projectPerUser:projectPerUserList){
                    Date startDateProjectResource= projectPerUser.Start_Date__c;
                    Date endDateProjectResource = projectPerUser.End_Date__c;
                    if((startDateProjectResource < startDate && endDateProjectResource < startDate)||(startDateProjectResource > endDate && endDateProjectResource > endDate)){
                        counter +=1;
                    }
                }
                if(counter != sizeList){
                    projectResource.addError('The date range chosen collides with the dates previously assigned to this resource');
                }
            }else{
                projectResource.addError('The dates must be within the date range of the Project to work on or The required role is different than the role of the resource');  
            }
        }
    }
}