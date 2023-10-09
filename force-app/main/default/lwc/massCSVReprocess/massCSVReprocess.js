import { LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import reprocess from '@salesforce/apex/MassCSVReprocessLWC.reprocess';
export default class MassCSVReprocess extends LightningElement {
    yearValue;
    monthValue;
    year;
    previousYear;
    nextYear;
    

    get monthOptions() {
        return [
            
                 { label: 'Jan', value: 'Jan' },
                 { label: 'Feb', value: 'Feb' },
                 { label: 'Mar', value: 'Mar' },
                 { label: 'Apr', value: 'Apr' },
                 { label: 'May', value: 'May' },
                 { label: 'Jun', value: 'Jun' },
                 { label: 'Jul', value: 'Jul' },
                 { label: 'Aug', value: 'Aug' },
                 { label: 'Sep', value: 'Sep' },
                 { label: 'Oct', value: 'Oct' },
                 { label: 'Nov', value: 'Nov' },
                 { label: 'Dec', value: 'Dec' },
               ];
    }


    get yearOptions() {
        let d = new Date();
        
        this.year = d.getFullYear().toString();
        this.previousYear = (d.getFullYear()-1).toString();
        this.nextYear = (d.getFullYear()+1).toString();
        
        return [
                 { label: this.previousYear, value: this.previousYear},
                 { label: this.year, value: this.year },
                 { label: this.nextYear, value: this.nextYear },
               ];
    }

    connectedCallback(){
        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
            ];

        let date = new Date();
        this.monthValue = monthNames[date.getMonth()];

        this.yearValue = date.getFullYear().toString();
    }

    handleChangeMonth(event){
        this.monthValue = event.detail.value;
    }
    handleChangeYear(event){
        this.yearValue = event.detail.value;
        console.log('prevYear=='+this.previousYear);
        console.log('currentYear=='+this.year);
        console.log('nextYear=='+this.nextYear);
        console.log('value=='+this.yearValue);
    }
    handleReprocess()
    {
        let year1 = this.yearValue.substring(2);
        let folder = `${this.monthValue}_${year1}`.trim();
        console.log(folder);
       reprocess({folderName:folder,month:this.monthValue , year:this.yearValue}).then(data=>{
            this.showToastmessage('Success','You will receive an Email once done','success');
        }) .catch((err) => {
            console.error(err);
            this.showToastmessage('Error','Error while reprocessing Mass CSV','error');
          }); 
    }
    showToastmessage(title,message,varient){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: varient,
            }),
        );
    }
}