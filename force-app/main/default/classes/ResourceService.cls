public class ResourceService {
    //---------------------------Insertando Recursos desde la Interfaz---------------------------//
    
    //Método que se encarga de Insertar registros, en el objeto "Project Resource" desde la interfaz.
    @auraEnabled
    public static List<User> registerResource(Id ProjectId,List<Map<String,Object>>selectedResources){
        system.debug('Estos son mis recursos seleccionados: '+selectedResources);
        system.debug('Estoy en proyecto : '+ProjectId);
        Project__c project = [
            SELECT Id,Start_Date__c,End_Date__c,(SELECT Id,Hours_To_Cover__c,Role__c FROM Required_Roles__r)
            FROM Project__c 
            WHERE Id=:projectId
        ];
        //Datos del Proyecto al que queremos asignar recursos.
        List<RequiredRole__c>requiredRoleList = project.Required_Roles__r;
        Date startDate = project.Start_Date__c;
        Date endDate = project.End_Date__c;
        set<Id>userIds = new set<Id>();
        for(Map<String,Object>resource:selectedResources){
            userIds.add((Id)resource.get('Id'));
        }
        //Query a Usurios con registros relacionados en el Objeto "Project Resource" que están trabajando
        //en fechas que interceptan a las fechas en las que se definió el Proyecto al que se les desea asignar.
        List<User>usersSelectedFromInterface = [
            SELECT Id,(SELECT Id,Start_Date__c,End_Date__c
                       FROM Project_Resources__r 
                       WHERE ((End_Date__c >=:startDate AND End_Date__c<=:endDate) 
                              OR (Start_Date__c>=:startDate AND Start_Date__c<=:endDate AND End_Date__c>=:endDate)) 
                       AND Required_Role__r.Project__r.Stage__c!='Completed' 
                       ORDER BY Start_Date__c ASC) 
            FROM User 
            WHERE Id In:userIds
        ];
        Map<Id,User> usersSelectedFromInterfaceMap = new Map<Id,User>(usersSelectedFromInterface);
        system.debug('MapDeUsuarios : '+usersSelectedFromInterfaceMap);
        List<Project_Resource__c>resourcesToInsert = new List<Project_Resource__c>();
        for(Map<String,Object>resource:selectedResources){
            system.debug('mi usuario : '+resource);
            Id selectedUserId = (Id)resource.get('Id');
            Date startDateFromInterface = Date.valueOf((String.valueOf(resource.get('dateApiNameSD'))));
            Date endDateFromInterface = Date.valueOf((String.valueOf(resource.get('dateApiNameED'))));
            //Listado de todos los registros en el objeto "Project_Resource__c" en el cual el usuario que estamos iterando es "Recurso".
            List<Project_Resource__c>projectPerUserList =usersSelectedFromInterfaceMap.get(selectedUserId).Project_Resources__r;
            //Inicialización de una instancia de "Project_Resource__c" la cual, si se cumplen condiciones, se le asignará el registro asignando el valor del campo "Resource__c" el usuario que estamos iterando.
            Project_Resource__c projectResource = new Project_Resource__c();
            if(projectPerUserList.size()>0){
                for(Project_Resource__c projectPerUser:projectPerUserList){
                    Date startDateProjectPerUser = projectPerUser.Start_Date__c;
                    Date endDateProjectPerUser = projectPerUser.End_Date__c;
                    if((startDateFromInterface>=startDateProjectPerUser && startDateFromInterface<=endDateProjectPerUser)||(endDateFromInterface>=startDateProjectPerUser && endDateFromInterface<=endDateProjectPerUser)){
                        system.debug('Este usuario No puede trabajar en este proyecto');
                        break;
                    }else{
                        projectResource.Resource__c = selectedUserId;
                        String Role =(String)resource.get('Role');
                        for(RequiredRole__c requiredRole:requiredRoleList){
                            if(requiredRole.Role__c == Role){
                                projectResource.Required_Role__c =requiredRole.Id;
                                break;
                            }
                        }
                        projectResource.Start_Date__c = startDateFromInterface;
                        projectResource.End_Date__c = endDateFromInterface;
                        system.debug('recurso con dato : '+projectResource);
                        resourcesToInsert.add(projectResource);
                    }
                }
            }else{ 
                projectResource.Resource__c = selectedUserId;
                String Role =(String)resource.get('Role');
                for(RequiredRole__c requiredRole:requiredRoleList){
                    if(requiredRole.Role__c == Role){
                        projectResource.Required_Role__c =requiredRole.Id;
                        break;
                    }
                }
                projectResource.Start_Date__c = startDateFromInterface;
                projectResource.End_Date__c = endDateFromInterface;
                system.debug('recurso con dato : '+projectResource);
                resourcesToInsert.add(projectResource);
            }
        }
        if(resourcesToInsert.size()>0){
            insert resourcesToInsert;
        }
        //Listado de Registros "Project_Resource__c" actualizados con los nuevos registros insertados en la línea 83.
        List<Project_Resource__c> listOfProjectResourceUpdated= [
            SELECT Required_Role__r.Project__r.Id,
            Resource__c From Project_Resource__c 
            WHERE Required_Role__r.Project__r.Id=:project.Id 
        ];
        set<Id> userSelectedIds = new set<Id>();
        for(Project_Resource__c resource:listOfProjectResourceUpdated){
            userSelectedIds.add(resource.Resource__c);
        } 
        //Listado actualizado de todos los Usuarios que son "Recursos" del Proyecto. 
        List<User> projectResourceList = [
            SELECT Id,Name,Role__c 
            From User 
            WHERE Id IN:userSelectedIds
        ];
        return projectResourceList;
    }
    //------------------------Gestión para servir los Recursos disponibles por cada Proyecto---------------------//
    
    //Método que devuelve la instancia de la clase "ResourceWrapper". 
    @AuraEnabled(cacheable=true)
    public static ResourceWrapper getResourcesWrapper(Id projectId){
        Project__c project = [
            SELECT Id, Start_Date__c,End_Date__c, (SELECT Id,Hours_To_Cover__c,Role__c FROM Required_Roles__r) FROM Project__c 
            WHERE Id=:projectId
        ];
        List<List<User>> resourcesAvailable = getResourcesWrap(project);
        //system.debug('Estos son mis recursos: '+resourcesAvailable);
        ResourceWrapper resourceWrap = new ResourceWrapper(project,resourcesAvailable);
        return resourceWrap;
    }
    //A través de este método, servimos todos los recursos que están disponibles, por todos los Roles, para trabajar en un determinado Proyecto.
    private static List<List<User>> getResourcesWrap(Project__c project){
        //Información de la instancia de "Project__c" que pasamos por parámetro:
        List<RequiredRole__c>  requiredRoleList = project.Required_Roles__r;
        Date startDate = project.Start_Date__c;
        Date endDate = project.End_Date__c;
        //Creamos una instancia de "List<Project_Resource__c>". El resultado de la query hecha a la base de datos listará información de los registros en "Project_Resource__c" cuyas fechas sobrepasan, o son iguales, al intervalo de fechas de un proyecto específico cuyo Id será necesario para filtrar nuestra búsqueda: -----SPR(---SP[------]EP---)EPR----. SPR:Start Project Resource, SP:Start Project, EPR: End Project Resource, EP:End Project. Usaremos esta información para luego acceder a los Id de los usuarios que no podrán trabajar en un Proyecto específico.
        List<Project_Resource__c> infoResourcesNotAvailable= [
            SELECT Required_Role__r.Project__r.Id,Resource__c, Start_Date__c,End_Date__c 
            FROM Project_Resource__c 
            WHERE (Start_Date__c <=:startDate AND End_Date__c >=:endDate) 
            OR Required_Role__r.Project__r.Id=:project.Id 
        ];
        Set<Id> resourcesNotAvailableId = new Set<Id>();
        for(Project_Resource__c projectResource:infoResourcesNotAvailable){
            resourcesNotAvailableId.add(projectResource.Resource__c);
        }
        //System.debug('Id que no quiero: '+resourcesNotAvailableId);
        List<List<User>>resourcesAvailable = new List<List<User>>();
        for(RequiredRole__c requiredRole:requiredRoleList){
            String Role = requiredRole.Role__c;
            List<User> resourcesAvailableXrole = resourceXrole(resourcesNotAvailableId,Role);
            resourcesAvailable.add(resourcesAvailableXrole);
        }
        return resourcesAvailable;
    }
    
    //Método que sirve los recursos que están disponibles por cada Rol que se necesite en el Proyecto. Sus parámetros serán un conjunto de Ids de los usuarios que no están disponibles para trabajar en el proyecto, de estos, tomaremos su complemento. Como segundo parámetro será el Rol del cual queremos listar los recursos disponibles. Este método será utilizado en el método "getResourcesWrap".
    private static List<User> resourceXrole(set<Id> resourceId,String Role){
        List<User> resourcesAvailableXrole = [
            SELECT Id,Name, Rate_p_hour__c,Role__c 
            FROM User 
            WHERE Role__c =:Role AND Id NOT IN: resourceId
        ];
        return resourcesAvailableXrole;
    }
    //Clase Wrapper//
    public class ResourceWrapper {
        @AuraEnabled
        public Project__c project;
        @AuraEnabled
        public List<List<User>> resources;
        public ResourceWrapper(Project__c project,List<List<User>> resources){
            this.project =project;
            this.resources = resources;
        }
    }
}


////////////////////////////////////////////////////////////Método registerResource/////////////////////////////////
/*
 * @auraEnabled
public static List<User> registerResource(Id ProjectId,List<Map<String,Object>>selectedResources){
//system.debug('Estos son mis recursos seleccionados: '+selectedResources);
//system.debug('Estoy en proyecto : '+ProjectId);
Project__c project = [
    SELECT Id,Start_Date__c,End_Date__c,(SELECT Id,Hours_To_Cover__c,Role__c FROM Required_Roles__r)
    FROM Project__c 
    WHERE Id=:projectId
    ];
//Datos del Proyecto al que queremos asignar recursos.
List<RequiredRole__c>requiredRoleList = project.Required_Roles__r;
Date startDate = project.Start_Date__c;
Date endDate = project.End_Date__c;
set<Id>userIds = new set<Id>();
for(Map<String,Object>resource:selectedResources){
        userIds.add((Id)resource.get('Id'));
    }
//Query a Usurios con registros relacionados en el Objeto "Project Resource" que están trabajando
//en fechas que interceptan a las fechas en las que se definió el Proyecto al que se les desea asignar.
List<User>usersSelectedFromInterface = [
    SELECT Id,(SELECT Id,Start_Date__c,End_Date__c
    FROM Project_Resources__r 
    WHERE ((End_Date__c >=:startDate AND End_Date__c<=:endDate) 
    OR (Start_Date__c>=:startDate AND Start_Date__c<=:endDate AND End_Date__c>=:endDate)) 
    AND Required_Role__r.Project__r.Stage__c!='Completed' 
    ORDER BY Start_Date__c ASC) 
    FROM User 
    WHERE Id In:userIds
    ];
Map<Id,User> usersSelectedFromInterfaceMap = new Map<Id,User>(usersSelectedFromInterface);
//system.debug('MapDeUsuarios : '+usersSelectedFromInterfaceMap);
List<Project_Resource__c>resourcesToInsert = new List<Project_Resource__c>();
for(Map<String,Object>resource:selectedResources){
        //system.debug('mi usuario : '+resource);
        Id selectedUserId = (Id)resource.get('Id');
        Date startDateFromInterface = Date.valueOf((String.valueOf(resource.get('dateApiNameSD'))));
        Date endDateFromInterface = Date.valueOf((String.valueOf(resource.get('dateApiNameED'))));
        //Listado de todos los registros en el objeto "Project_Resource__c" en el cual el usuario que estamos iterando es "Recurso".
        List<Project_Resource__c>projectPerUserList =usersSelectedFromInterfaceMap.get(selectedUserId).Project_Resources__r;
        //Inicialización de una instancia de "Project_Resource__c" la cual, si se cumplen condiciones, se le asignará el registro asignando el valor del campo "Resource__c" el usuario que estamos iterando.
        Project_Resource__c projectResource = new Project_Resource__c();
        if(projectPerUserList.size()>0){
            for(Project_Resource__c projectPerUser:projectPerUserList){
                Date startDateProjectPerUser = projectPerUser.Start_Date__c;
                Date endDateProjectPerUser = projectPerUser.End_Date__c;
                if((startDateFromInterface>=startDateProjectPerUser && startDateFromInterface<=endDateProjectPerUser)||(endDateFromInterface>=startDateProjectPerUser && endDateFromInterface<=endDateProjectPerUser)){
                    //system.debug('Este usuario No puede trabajar en este proyecto');
                    break;
                }else{
                    projectResource.Resource__c = selectedUserId;
                    String Role =(String)resource.get('Role');
                    for(RequiredRole__c requiredRole:requiredRoleList){
                        if(requiredRole.Role__c == Role){
                        projectResource.Required_Role__c =requiredRole.Id;
                        break;
                        }
                    }
                    projectResource.Start_Date__c = startDateFromInterface;
                    projectResource.End_Date__c = endDateFromInterface;
                    //system.debug('recurso con dato : '+projectResource);
                    resourcesToInsert.add(projectResource);
                }
            }
        }else{ 
                projectResource.Resource__c = selectedUserId;
                String Role =(String)resource.get('Role');
                for(RequiredRole__c requiredRole:requiredRoleList){
                    if(requiredRole.Role__c == Role){
                        projectResource.Required_Role__c =requiredRole.Id;
                        break;
                    }
                }
                projectResource.Start_Date__c = startDateFromInterface;
                projectResource.End_Date__c = endDateFromInterface;
                //system.debug('recurso con dato : '+projectResource);
                resourcesToInsert.add(projectResource);
            }
    }
        if(resourcesToInsert.size()>0){
        insert resourcesToInsert;
    }
    //Listado de Registros "Project_Resource__c" actualizados con los nuevos registros insertados en la línea 83.
    List<Project_Resource__c> listOfProjectResourceUpdated= [
        SELECT Required_Role__r.Project__r.Id,
        Resource__c From Project_Resource__c 
        WHERE Required_Role__r.Project__r.Id=:project.Id 
        ];
    set<Id> userSelectedIds = new set<Id>();
    for(Project_Resource__c resource:listOfProjectResourceUpdated){
        userSelectedIds.add(resource.Resource__c);
    } 
    //Listado actualizado de todos los Usuarios que son "Recursos" del Proyecto. 
    List<User> projectResourceList = [
        SELECT Id,Name,Role__c 
        From User 
        WHERE Id IN:userSelectedIds
        ];
    return projectResourceList;
}*/