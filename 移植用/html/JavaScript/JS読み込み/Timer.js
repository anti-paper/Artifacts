class calc{
    getSecond(t){
        return t%60;
    }

    getMinute(t){
        return (t-this.getSecond(t))/60;
    }

    judge(t){
        if(t<10){
            return "0"+t;
        }else{
            return t+"";
        }
    }

    timeFormat(t){
        return this.judge(this.getMinute(t))+":"+this.judge(this.getSecond(t));
    }
}

var t_1,t_2;

function startTimer(){
    if(t_1<=0){
        clearInterval();
    }else{
        var t=new calc;
        var frm_txt=t.timeFormat(t_1);
        document.getElementById("znr").innerHTML=frm_txt;
        t_1--;
    }
}

function stopTimer(){
    t_1=-1;
    window.alert("タイマーを中止しました。");
    location.reload();
}

function endTimer(){
    window.alert(t_2+"分が経過しました。\nタイマーを終了します。");
    location.reload();
}

function webTimer(){
    t_1=window.prompt("時間（分）を指定してください",60);
    t_2=t_1;
    t_1*=60;
    setInterval('startTimer()',1000);
    
    if(t_1!=-1){
        setTimeout('endTimer()', Number(t_2)*60000+1000);
    }
}