<?php
$md5file = file_get_contents("/public_html/md5file.txt");

if (md5_file("/public_html/current_ip.txt") == $md5file)
  {
  echo "The file is ok.";
  }
else
  {
$file = '/public_html/current_ip.txt';
$remote_file = '/public_html/current_ip.txt';

$ftp_user_name = "liftven";
$ftp_user_pass = "3WqzmN5XCh";
$ftp_server = "ftp.liftven.com";

// establecer una conexión básica
$conn_id = ftp_connect($ftp_server);

// iniciar sesión con nombre de usuario y contraseña
$login_result = ftp_login($conn_id, $ftp_user_name, $ftp_user_pass);

// cargar un archivo
if (ftp_put($conn_id, $remote_file, $file, FTP_ASCII)) {
 echo "se ha cargado $file con éxito\n";
} else {
 echo "Hubo un problema durante la transferencia de $file\n";
}

// cerrar la conexión ftp
ftp_close($conn_id);

$md5file = md5_file("/public_html/current_ip.txt");
file_put_contents("/public_html/md5file.txt",$md5file);

}
?>

