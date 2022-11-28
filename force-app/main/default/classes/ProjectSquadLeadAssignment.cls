public class ProjectSquadLeadAssignment {
    //------------------Método para ser llamado desde el Trigger "ProjectSquadLeadAssignment"-------------------//
    public static void onBeforeUpdate(List<Project__c>ProjectList,Map<Id,Project__c>ProjecMapOld){
        //Crearemos un subconjunto de Ids desde los Ids de "ProjectList" (Es decir, desde Trigger.New).
        set<Id>filteredProjectListIds = new set<Id>();
        for(Project__c project:ProjectList){
            if(project.Squad_Lead__c!=ProjecMapOld.get(project.Id).Squad_Lead__c){
                filteredProjectListIds.add(project.Id);
            }
        }
        //A continuación, listamos los "Project Resource" que están relacionados, como "nietos", a los proyectos que dispararon en un subconjunto de Trigger.New, aquellos cuyos Ids están en el set "filteredProjectListIds".
        List<Project_Resource__c>projectResourceList =[
            SELECT Id,Resource__c,Required_Role__r.Project__r.Id 
            FROM Project_Resource__c 
            WHERE Required_Role__r.Project__r.Id IN:filteredProjectListIds
        ];
        //A continuación crearemos una lista de Maps cuya "key" será el Id del proyecto que dispara el Trigger  cuyo "Value" serán todos los
        //registros de "Project Resource" relacionados, como "nietos" al proyecto.
        Map<Id,List<Project_Resource__c>>projectResourceMap =new Map<Id,List<Project_Resource__c>>();
        for(Project_Resource__c projectResource:projectResourceList){
            if(projectResourceMap.containsKey(projectResource.Required_Role__r.Project__r.Id)){
                projectResourceMap.get(projectResource.Required_Role__r.Project__r.Id).add(projectResource);
            }else{
                projectResourceMap.put(projectResource.Required_Role__r.Project__r.Id,new List<Project_Resource__c>{projectResource});
            }
        }
        //Iteraremos sobre cada Proyecto que disparo el Trigger para verificar que el "Squad Lead" que se le asigne es un "Recurso" que trabaja para dicho proyecto.
        for(Project__c project:ProjectList){
            List<Project_Resource__c>resourcesOfThisProject = projectResourceMap.get(project.Id);
            Integer numberOfResourcesInTheProject = resourcesOfThisProject.size();
            Integer counter = 0;
            for(Project_Resource__c resource:resourcesOfThisProject){
                if((project.Squad_Lead__c == resource.Resource__c)||(project.Squad_Lead__c==null)){
                    break;
                }else{
                    counter +=1;
                }
            }
            if(numberOfResourcesInTheProject == counter){
                project.addError('Please, assign a project resource from this project as the Squad Lead.');
            }
        }
    }
}