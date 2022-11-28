import { LightningElement,api } from 'lwc';

const columns = [
{ label: 'Name',
 fieldName: 'Name',
 iconName:'utility:user_role'
 },
{
    label: 'Rate p/hour',
     fieldName: 'Rate_p_hour__c',
     type: 'currency',
     iconName: 'utility:money',
     typeAttributes: { currencyCode: 'CLP' },
     cellAttributes: { alignment: 'left' }
},
{
label: 'Start Date',
fieldName: 'dateApiNameSD',
type: 'date-local',
iconName:'utility:event',
editable: true,
typeAttributes: {
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }
},{
label: 'End Date',
fieldName: 'dateApiNameED',
type: 'date-local',
iconName:'utility:event',
editable: true,
typeAttributes: {
    year: "numeric",
    day: "2-digit",
    month: "2-digit",
    
}

},
];

export default class ResourcesTable extends LightningElement {
columns = columns;
draftValues=[];
@api resources;
///
@api startDate;
@api endDate;
///
///Manejo de Errores//
errors;

////////////////////////////////////////////Manejo de Errores por Celda/////////////////

handleErrors(event){
    const draftValues=event.target.draftValues;
    this.errors={};
    const myResources= this.resources;
    for(let i=0; i< myResources.length; i++){
        for(let j =0; j<draftValues.length;j++){
            if(draftValues[j].dateApiNameSD != null && draftValues[j].dateApiNameED != null ){
               if(draftValues[j].dateApiNameSD>draftValues[j].dateApiNameED){
                  let error = {};
                            error.rows = {};
                            error.rows[draftValues[j].Id] = { title: 'Too much coffee??..',
                             messages: [ 'The start date cannot be later than the end date'],
                              fields: ['dateApiNameSD', 'dateApiNameED']
                            };
                  this.errors = error;
                }else if(draftValues[j].dateApiNameSD < this.startDate || draftValues[j].dateApiNameED > this.endDate){
                   let error = {};
                            error.rows = {};
                            error.rows[draftValues[j].Id] = { title: 'Please check your input',
                            messages: [ `Dates should be between ${this.startDate} and ${this.endDate}.`],
                              fields: ['dateApiNameSD', 'dateApiNameED']
                            };
                   this.errors = error; 
             }
          }else if((draftValues[j].dateApiNameSD != null && draftValues[j].dateApiNameED == null )||(draftValues[j].dateApiNameSD == null && draftValues[j].dateApiNameED != null )){
             let error = {};
                     error.rows = {};
                     error.rows[draftValues[j].Id] = { title: 'Please check your input',
                     messages: ['Please, complete both date fields'],
                     fields: ['dateApiNameSD', 'dateApiNameED']
                    };
             this.errors = error; 
          }
        }
    }
}

//////////////////////////////////////////////////
handleSelectedRows(event){
const rowsSelected=event.detail.selectedRows;
const draftValues=event.target.draftValues;
let eventAuxiliar=[];
let mapa={};
for(let i=0; i< rowsSelected.length; i++){
    for(let j =0; j<draftValues.length;j++){
        if(draftValues[j].dateApiNameSD != null && draftValues[j].dateApiNameED != null ){
            //agregado el chequeo de fechas ciertas
                if(draftValues[j].dateApiNameSD < this.startDate || draftValues[j].dateApiNameED > this.endDate){
                    console.log(`no se puede procesar la solicitud para ${rowsSelected[i].Name} la fecha de inicio y fin deben estar dentro del rango del proyecto`)
                                
                //Agregado notificacion
                } else if(draftValues[j].dateApiNameSD>draftValues[j].dateApiNameED){
                    console.log(`no se puede procesar la solicitud para ${rowsSelected[i].Name} La fecha de inicio nunca puede ser mayor a la de fin`);
                } else {
                        if(draftValues[j].Id==rowsSelected[i].Id){
                            mapa={};
                            mapa=draftValues[j];
                            mapa["Role"]=rowsSelected[i].Role__c;
                            eventAuxiliar.push(mapa);
            
                        }
        }
}
    }
}
console.log('Este es el evento Auxiliar:' + eventAuxiliar);
const selectedResources = new CustomEvent('selected', { 
    detail: {
        listOfSelectedResources: eventAuxiliar
    }
});
this.dispatchEvent(selectedResources);
}


}