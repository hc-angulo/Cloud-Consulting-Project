import { LightningElement, wire, api } from 'lwc';
import getTasks from '@salesforce/apex/TaskService.getTasks';
import uId from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
export default class TotalTasks extends LightningElement {
    userId = uId;
    allTasks;
    error;
    _wireResult;
    //tasksSize;

    @api
    async refresh() {
          await refreshApex(this._wireResult);
    }

    @wire (getTasks,{currentUser:'$userId'})
    wireTask(Result){
        const { data, error } = Result;
        this._wireResult=Result;
        if (data) {
            console.log('Longitud:'+data.length)
            console.log('Mis tareas desde JS: '+JSON.stringify(data));
            this.allTasks = data;
           // this.tasksSize=data.length;
        } else if (error){
                this.error = error;
                console.log(error);
        }
    }

   

    
    async refresh() {
          await refreshApex(this._wireResult);
    }

   

    updateTasks(event) {
         this.refresh(); 
    }




}