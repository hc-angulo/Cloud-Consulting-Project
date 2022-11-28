import { LightningElement,api } from 'lwc';

export default class TableHeader extends LightningElement {
    @api
index;
@api
hr;
@api
iconsRole;
@api
role;

get title(){
    return this.role+'- Horas a cubrir : ' + this.hr[this.index];
}

get icon(){
    if(this.role == "Developer"){
        return this.iconsRole[0];
    }else if(this.role == "Consultant"){
        return this.iconsRole[1];
    }else if(this.role =="Architect"){
        return this.iconsRole[2];
    }
    
}
}