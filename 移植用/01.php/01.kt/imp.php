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
                    <title>筋トレ記録復元</title>
                </head>
                <body>
    eot1;

    /* restore record data */
    $csv=isset($_GET["csv"])?htmlspecialchars($_GET["csv"]):null;
    if($csv<>""){
        $sql_1=$s->query("load data infile '{$csv}' into table re ignore 1 line");
        print "インポートされました。<br><br>";
    }else{
        print <<<eot2
            <font color="red">
                インポートするCSVファイルのパスを指定してください。
            </font><br><br>
        eot2;
    }
    
    /* form */
    print <<<eot3
        <form method="get" action="rest.php">
            <input type="text" name="csv">
            <input type="submit" value="復元">
        </form><br><br>
    eot3;

    /* write link,html */
    print "<a href='top.html'>トップページに戻る</a>";
    print <<<eot4
            </body>
        </html>
    eot4;
?>