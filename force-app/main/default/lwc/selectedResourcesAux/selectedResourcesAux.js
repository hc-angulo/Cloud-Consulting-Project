import { LightningElement, api, wire,track} from 'lwc';
import listOfSelectedResources from '@salesforce/apex/ManagementOverSelectedResources.listOfSelectedResources';
// import RESOURCESMC from the message channel
import RESOURCESMC from '@salesforce/messageChannel/ResourceMessageChannel__c';
import { subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
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
export default class SelectedResourcesAux extends LightningElement {
    @api recordId;
    columns = columns;
   subscription = null;
    @track resources;


// Initialize messageContext for Message Service
  @wire(MessageContext)
  messageContext;

  @wire(listOfSelectedResources,{projectId: '$recordId'})
    resource(Result){
     const { data, error } = Result;
     
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
}