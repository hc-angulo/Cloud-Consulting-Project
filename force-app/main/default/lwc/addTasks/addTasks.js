import { LightningElement, api} from 'lwc';
export default class AddTasks extends LightningElement {
    @api tasks;

    get projectName(){
        if(this.tasks.length>0){
            return this.tasks[0].Project__r.Name + ' - ' + this.tasks.length + ' Pending Task';
        }else {
            return 'No Pending Task';
        }
    }

}