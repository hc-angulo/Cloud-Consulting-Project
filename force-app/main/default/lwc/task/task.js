import { LightningElement, api} from 'lwc';
import registerHours from '@salesforce/apex/TaskService.registerHours';
import updateTaskState from '@salesforce/apex/TaskService.updateTaskState';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const SUCCESS_TITLE = 'Success';
const SUCCESS_VARIANT = 'success';
const INFO_VARIANT = 'info';
export default class Task extends LightningElement {
    @api task;
    hours;

    @api
    get taskStarted(){
        if (this.task.State__c == 'In progress') {
            return true;
        }else {
            return false;
        }
    }

    handleInput(event) {
        this.hours = event.target.value;
    }

    handleLoadHours() {
        registerHours({taskId:this.task.Id, hoursToAdd:this.hours})     
        .then(result => {
            if(result==true){  
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: this.hours + ' Hours Added To ' + this.task.Name,
                        variant: INFO_VARIANT
                    })
                );
                this.hours = null;
                return this.updateTask();
            }
        })
        .catch(error=> console.log(JSON.stringify(error) + " Este es mi error")) 
    }

    handleMarkCompleted() {
        let status = '';
        if (this.task.State__c==='In progress') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: SUCCESS_TITLE,
                    message: this.task.Name + ' Completed',
                    variant: SUCCESS_VARIANT
                })
            );
            status='Completed';
        }
        if (this.task.State__c==='Not started yet') {
            status = 'In progress';
            this.taskStarted=true;
        }
        
        updateTaskState({taskId:this.task.Id, state:status})
        .then(result => {
            if (result==true) {
                return this.updateTask();
            }
        })
        .catch(
            error=> console.log(JSON.stringify(error) + " Este es mi error")
        )
    }


    updateTask() {
        const hoursAdded = new CustomEvent('hoursadded', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(hoursAdded);    
    }

}