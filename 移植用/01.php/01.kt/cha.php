<?php
    /* read db_info */
    require_once("data/db_info.php");

    /* connect and select database */
    $s=new PDO("mysql:host=$SERV;dbname=$DBNM",$USER,$PASS);

    /* write html */
    print <<<eot1
        <!DOCTYPE html>
            <html>
                <head>
                    <meta http-equiv="Content-Type" content="text/html;charset=Shift_JIS">
                    <title>筋トレ回数変更</title>
                </head>
                <body>
    eot1;
    /* change ct */
    $ct=isset($_GET["ct"])?htmlspecialchars($_GET["ct"]):null;
    if($ct<>""){
        if(preg_match("/[^0-9]/",$ct)){
            print <<<eot
                <font size="5" color="red">
                    半角の数字を入力してください。
                </font>
                <br><br>
            eot;
        }else{
            $sql_1=$s->query("update ks set ct={$ct} where nb=1");
            print <<<eot2
                <font size="5">
                    回数を変更しました。
                </font>
                <br><br>
            eot2;
        }
    }

    /* ct change form */
    $sql_2=$s->query("select * from ks where nb=1");
    $res_2=$sql_2->fetch(PDO::FETCH_ASSOC);
    print <<<eot3
        <form method="get" action="cha.php">
            回数：
            <input type="text" name="ct" value={$res_2['ct']}>
            <input type="submit" value="変更">
        </form><br><br>
    eot3;

    /* write link,html */
    print "<a href='top.html'>トップページに戻る</a>";
    print <<<eot4
            </body>
        </html>
    eot4;
?>