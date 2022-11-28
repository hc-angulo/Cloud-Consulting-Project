import { LightningElement, api, wire} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';

import getResourcesWrapper from '@salesforce/apex/ResourceService.getResourcesWrapper';
///Creación de Registros Project Resource///
import registerResource from '@salesforce/apex/ResourceService.registerResource';
/// Recursos seleccionados para que trabajen en Proyecto///
import listOfSelectedResources from '@salesforce/apex/ManagementOverSelectedResources.listOfSelectedResources';

////
// import RESOURCESMC from the message channel
import RESOURCESMC from '@salesforce/messageChannel/ResourceMessageChannel__c';
//Importado ToastEvent
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ResourceAllocation extends LightningElement {
    @api recordId;
    error;
    ProjectStartDate;
    ProjectEndDate;
   _wireResult;
    arreglo=[];
    roleArray= ['Developer','Consultant','Architect'];
    allResources;
    _hours;
    iconsRole=["custom:custom27","custom:custom63","custom:custom67"];
    //////
    architectRole=[];
    developerRole=[];
    consultantRole=[];
    arrayComplete=[];
    architectRoleTraducido=[];
    developerRoleTraducido=[];
    consultantRoleTraducido=[];
    arrayCompleteTraducido=[];
    //////TAMAÑO DE LOS YA INSERTADOS////
    
    resourceSize;
    errorResource;
    @wire(listOfSelectedResources,{projectId: '$recordId'})
    selected(Result){
     const { data, error } = Result;
     if (data) {
       this.resourceSize=data.length;
     } else if (error) {
         this.errorResource = error;
     }
    }


       // wired message context
       @wire(MessageContext)
       messageContext;
      
       // Publishes the selected boat Id on the BoatMC.
    sendMessageService(resourcesSelected) { 
        // explicitly pass boatId to the parameter recordId
        publish(this.messageContext, RESOURCESMC, { resourceList: resourcesSelected });
    }

    @api
    async refresh() {
          await refreshApex(this._wireResult);
      }

                                                                           
    @wire(getResourcesWrapper,{projectId: '$recordId'})
    resource(Result){
     const { data, error } = Result;
     this._wireResult=Result;
     if (data) {
      // debugger
        this.allResources = data.resources;
        console.log('Mis this.allResources:'+this.allResources);
        console.log('Mis this.allResources traducido: '+JSON.stringify(this.allResources));
        let vector=[];
        this.allResources.forEach((element, index) => {
            vector[index]=data.project.Required_Roles__r[index].Hours_To_Cover__c;
            

        });

        this._hours=vector;
        this.ProjectStartDate = data.project.Start_Date__c;
        this.ProjectEndDate = data.project.End_Date__c;

     } else if (error) {
         this.error = error;
     }
    }

    renderedCallback(){
        this.refresh();
    }

 handleSelected(event){
    this.arrayComplete=[];
    this.arrayCompleteTraducido=[];
    const capturador = event.detail.listOfSelectedResources;
    if(capturador.length>0){
        if(capturador[0].Role =='Developer'){
            this.developerRole = capturador;
            this.developerRoleTraducido=JSON.stringify(this.developerRole);
            console.log('Traducido:'+this.developerRoleTraducido);
            console.log('Developer:'+this.developerRole);
        }else if(capturador[0].Role =='Consultant'){
            this.consultantRole = capturador;
            this.consultantRoleTraducido = JSON.stringify(this.consultantRole);
            console.log(this.consultantRoleTraducido);
            console.log('Consultant:'+this.consultantRole);
        }else{
            this.architectRole = capturador;
            this.architectRoleTraducido=JSON.stringify(this.architectRole);
            console.log(this.architectRoleTraducido);
            console.log('Arquitect:'+this.architectRole);
            
        }
   
       

    }
    this.arrayCompleteTraducido=this.arrayCompleteTraducido.concat(this.developerRoleTraducido,this.consultantRoleTraducido,this.architectRoleTraducido);
    console.log(this.arrayCompleteTraducido);
    this.arrayComplete =this.arrayComplete.concat(this.developerRole,this.consultantRole,this.architectRole);
    
}

handleClick(event){
  if(this.arrayComplete.length>0){
    registerResource({ProjectId: this.recordId, selectedResources:this.arrayComplete})

          .then(resultado => {
            
            console.log('Resultado desde resourceAllocation:'+resultado);
            this.sendMessageService(resultado);
            console.log('Longitud de Usuarios insertados'+resultado.length);
            console.log('Longitud de los que deseo insertar'+this.arrayComplete.length);
            console.log('this.resourceSize'+this.resourceSize);
              if((resultado.length -this.arrayComplete.length ==this.resourceSize)||(resultado.length==this.arrayComplete.length)){
                const toast = new ShowToastEvent({
                  title:'Successful insertion',
                  message:'Your resources have been inserted',
                  variant: 'Success',
              });
              this.dispatchEvent(toast);
              this.arrayComplete=[];
              return this.refresh();
                
               }else{
                const toast = new ShowToastEvent({
                  title:'Insert Failed',
                  message:'Please check the dates of the resources that were not inserted',
                  variant: 'warning',
              });
                  this.dispatchEvent(toast);
                  return this.refresh();
               }
               
           })
           .catch(error=> console.log(JSON.stringify(error) + " Este es mi error"))
        }else{
            const toast = new ShowToastEvent({
                title:'Insert failed',
                message:'Please, check the box of the resources you want to select.',
                variant: 'Error',
            });
                this.dispatchEvent(toast);
        }
}

}

