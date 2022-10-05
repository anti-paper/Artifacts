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
                    <meta http-equiv="Content-Type" content="text/html;charset=Shift_JIS">
                    <title>筋トレ結果記録</title>
                </head>
                <body>
    eot1;
    
    /* get date */
    $day1=new Datetime("2020/03/18");
    $day2=new Datetime();
    $day2_f=$day2->format("yy/m/d");
    print "<h2>".$day2_f."</h2>";
    $diff=$day1->diff($day2);
    $diff_f=$diff->format("%a")+1;
    print "<h2>筋トレを始めてから今日で".$diff_f."日です。</h2><br><br>";
    
    /* write html */
    print <<<eot2
        <font size="5" color="red">
            本日の筋トレメニューはこちら↓
        </font>
        <br><br>
    eot2;

    /* get training data */
    $dd=(($diff_f-1)%3)+1;
    $sql_1=$s->query("select * from mn where nb=$dd");
    $res_1=$sql_1->fetch(PDO::FETCH_ASSOC);
    $sql_2=$s->query("select * from ks");
    $res_2=$sql_2->fetch(PDO::FETCH_ASSOC);
    $tp=$res_1['tp'];
    $ct=$res_2['ct'];
    print "種類：{$tp}<br>";
    print "回数：{$ct}回<br><br>";

    /* form */
    print <<<eot3
        <form method="get" action="che.php">
            <input type="text" name="dt" value={$day2_f} hidden="true">
            <input type="text" name="tp" value={$tp} hidden="true">
            <input type="text" name="ct" value={$ct} hidden="true">
            <input type="submit" value="記録">
        </form><br><br>
    eot3;

    /* write link,html */
    print "<a href='top.html'>トップページに戻る</a>";
    print <<<eot4
            </body>
        </html>
    eot4;
?>