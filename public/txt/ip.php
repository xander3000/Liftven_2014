
<?php


$externalIP = file_get_contents('http://phihag.de/ip/');
echo $externalIP;


$myFile = "/public_html/current_ip.txt";
$fh = fopen($myFile, 'w') or die("can't open file");
$ip = $externalIP;
fwrite($fh, $ip);
fclose($fh);
?>


<!--

		// Obtener IP

		$ip = $this->input->ip_address();
	
		// IP de la abse de datos
		
		$this->db->select('ip');
		$this->db->from('tabla');
		
		//condicional para usuario en acceso
		$this->db->where('user_id', $id);
		
		$query = $this->db->get();
		
		//Si:
		if ($ip != $query->row()->ip)
		{
			$query = $this->db->query("UPDATE players p, accuracy a SET p.ip='$ip',
						a.ip='$ip' WHERE a.user_id='$id' AND p.user_id='$id'");
			return TRUE;
		}
		else 
		{
		//No:
			return FALSE;
		}
	}	
-->
