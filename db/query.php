<?php
$databasehost='lesz.mariadb.database.azure.com';
$databaseuser='leszek@lesz';
$databasepass='te4ejafu!';
$databasename='fyp';
$db=mysqli_connect($databasehost,$databaseuser,$databasepass,$databasename) or die ("Connection failed!");
$sql="
select * from result2;
";
$result = $db->multi_query($sql);

$print = "";

if ($err=mysqli_error($db)) { $print.= $err."<br><hr>"; }

if ($result) {
  do {
  if ($res = $db->store_result()) {
    $print.="<table width=100% border=0><tr>";

      // printing table headers
      for($i=0; $i<mysqli_num_fields($res); $i++)
      {
          $field = mysqli_fetch_field($res);
          $print.= "<td bgcolor=lightgray><b>{$field->name}</b></td>";
      }
      $print.= "</tr>\n";

      // printing table rows
      while($row = $res->fetch_row())
      {
          $print.= "<tr>";
          foreach($row as $cell) {
            if ($cell === NULL) { $cell = '(null)'; }
            $print.= "<td>$cell</td>";
          }
          $print.= "</tr>\n";
      }
      $res->free();
      $print.= "</table>";

    }
  } while ($db->more_results() && $db->next_result());
}
$db->close();
$html = '<html>
    <head>
    </head>
    <body>'. $print .'</body>
</html>';
file_put_contents('./file.html', $html);
?>