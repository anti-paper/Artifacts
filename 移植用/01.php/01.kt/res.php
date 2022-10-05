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
                    <title>記録リセット</title>
                </head>
                <body>
    eot1;

    /* reset ct data */
    $damm=isset($_GET["damm"])?htmlspecialchars($_GET["damm"]):null;
    if($damm<>""){
        $sql_1=$s->query("delete from re");
        $sql_2=$s->query("alter table re auto_increment=0");
        print "リセットしました。<br><br>";
    }
    
    /* form */
    print <<<eot3
        <form method="get" action="res.php">
            <input type="text" name="damm" value='damm' hidden="true">
            <input type="submit" value="リセット">
        </form><br><br>
    eot3;

    /* write link,html */
    print "<a href='top.html'>トップページに戻る</a>";
    print <<<eot4
            </body>
        </html>
    eot4;
?>