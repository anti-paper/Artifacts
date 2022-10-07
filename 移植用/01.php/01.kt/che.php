<?php
    /* read db_info */
    require_once("data/db_info.php");

    /* connect and select database */
    $s=new PDO("mysql:host=$SERV;dbname=$DBNM",$USER,$PASS);

    /* set timezone */
    date_default_timezone_set("Asia/Tokyo");

    /* write html */
    print <<<eot1
        <!DOCTYPE html>
            <html>
                <head>
                    <link rel="stylesheet" type="text/css" href="ss.css">
                    <meta http-equiv="Content-Type" content="text/html;charset=Shift_JIS">
                    <title>筋トレ記録確認</title>
                </head>
                <body>
    eot1;

    /* check got data */
    $dt=isset($_GET["dt"])?htmlspecialchars($_GET["dt"]):null;
    if($dt<>""){
        $sql_1=$s->query("select count(nb) from re where dt='{$dt}'");
        $res_1=$sql_1->fetch(PDO::FETCH_ASSOC);
        if($res_1["count(nb)"]==0){
            $sqlstr=<<<eot
                insert into re(dt,tp,ct) values("{$dt}","{$_GET['tp']}",{$_GET['ct']})
            eot;
            $sql_2=$s->query($sqlstr);
            print <<<eot2
                <font size="5">
                    記録が完了しました。
                </font>
                <br><br>
            eot2;
        }else{
            print <<<eot3
                <font size="5" color="red">
                    本日の筋トレ結果は既に記録されています。
                </font>
                <br><br>
            eot3;
        }
    }

    /* record visible */
    $sql_3=$s->query("select * from re");
    print "<table>";
    print "<tr><th>日付</th>";
    print "<th>種類</th>";
    print "<th>回数</th></tr>";

    while($res_3=$sql_3->fetch(PDO::FETCH_ASSOC)){
        print <<<eot4
            <tr>
                <td>{$res_3["dt"]}</td>
                <td>{$res_3["tp"]}</td>
                <td>{$res_3["ct"]}</td>
            </tr>
        eot4;
    }

    print "</table><br><br>";

    /* write link,html */
    print "<a href='top.html'>トップページに戻る</a>";
    print <<<eot5
            </body>
        </html>
    eot5;
?>