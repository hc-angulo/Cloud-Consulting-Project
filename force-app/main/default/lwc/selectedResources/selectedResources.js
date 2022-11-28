import { LightningElement, api, wire,track} from 'lwc';
import listOfSelectedResources from '@salesforce/apex/ManagementOverSelectedResources.listOfSelectedResources';
import deleteResources from '@salesforce/apex/ManagementOverSelectedResources.deleteResources';
import registerSquadLead from '@salesforce/apex/ManagementOverSelectedResources.registerSquadLead';
import { refreshApex } from '@salesforce/apex';
// import RESOURCESMC from the message channel
import RESOURCESMC from '@salesforce/messageChannel/ResourceMessageChannel__c';
import {subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
//Importado ToastEvent
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name',
     fieldName:'Name',
     iconName:'utility:user'
    },
    { label: 'Role',
     fieldName:'Role__c',
     iconName:'utility:custom_apps'
    }
];
export default class SelectedResources extends LightningElement {
@api recordId;
columns = columns;
@track _wireResult;
resources;
subscription = null;
eventAuxiliar=[];
resourceSize;



// Initialize messageContext for Message Service
@wire(MessageContext)
messageContext;


@api
async refresh() {
      await refreshApex(this._wireResult);
  }

@wire(listOfSelectedResources,{projectId: '$recordId'})
    resource(Result){
     const { data, error } = Result;
     this._wireResult=Result;
     if (data) {
       this.resources = data;
       this.resourceSize=data.length;
       console.log('Estos son mis datos:'+data);
    } else if (error) {
         this.error = error;
         console.log('Este es el error:'+error);
     }
    }


    // Subscribes to the message channel
    subscribeMC() {
        // recordId is populated on Record Pages, and this component
        // should not update when this component is on a record page.
        if (this.subscription) {
          return;
        }
        // Subscribe to the message channel to retrieve the recordId and explicitly assign it to boatId.
        this.subscription = subscribe(
            this.messageContext,
            RESOURCESMC,
            (message) => {this.resources = message.resourceList;
                console.log('Mis this.resources'+this.resources);
                console.log('me llegó desde APEX:'+message.resourceList);
            },
            { scope: APPLICATION_SCOPE }
          );
      }

      // Calls subscribeMC()
      connectedCallback() {
        this.subscribeMC();
      }
    

  

      handleSelectedRows(event){
        this.rowsSelected=event.detail.selectedRows;
        console.log('Mis filas seleccionadas:'+this.rowsSelected);
        console.log(JSON.stringify(this.rowsSelected));
        this.eventAuxiliar =this.rowsSelected;
     }

     handleClickDelete(){
        console.log('Click en Boton de Delete');
        if(this.eventAuxiliar.length>0){
       deleteResources({projectId:this.recordId,selectedResources:this.eventAuxiliar})
        .then(resultado => {
           const toast = new ShowToastEvent({
                title:'Successful removal',
                message:'The selected resources have been deleted successfully.',
                variant: 'Success',
            });
                this.dispatchEvent(toast);
            return this.refresh();
        })
        .catch(error=> console.log(JSON.stringify(error) + " Este es mi error"));
    }else{
        const toast = new ShowToastEvent({
            title:'Delete failed',
            message:'Please, select the resources you want to delete.',
            variant: 'Error',
        });
            this.dispatchEvent(toast);
    }
      

     }

     handleSquadLead(){
        console.log('Click en Boton de Squad Lead');
        if(this.eventAuxiliar.length>0){
            registerSquadLead({projectId:this.recordId,selectedResource:this.eventAuxiliar})
            .then(resultado => {
                console.log(resultado);
                this.template.querySelector('lightning-datatable').selectedRows = [];
                const toast = new ShowToastEvent({
                    title:'Successful Squad Lead insertion',
                    message:'You have selected '+resultado.Name+' as your Squad Lead.',
                    variant: 'Success',
                });
                this.dispatchEvent(toast);
            })
            .catch(error=> console.log(JSON.stringify(error) + " Este es mi error al insertar squad lead"));
        }else{
            const toast = new ShowToastEvent({
                title:'Squad Lead insertion failed',
                message:'Please, select a resource.',
                variant: 'Error',
            });
                this.dispatchEvent(toast);
        }

        
     }
}