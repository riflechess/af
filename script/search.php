<html>
<head>
<title>JFK Assasination Archival Search</title>
<meta name="description" content="Full-text indexed, OCR'd search of the John F. Kennedy Assassination Documents, declassified in 2017.">
<meta name="keywords" content="JFK, Kennedy, Assasination, CIA, FBI, Documents, Search, Full-text, fulltext.">
</head>
<style>

table {
    width: 100%;
    border-collapse: collapse;
}
table, td, th {
    border: 0px solid black;
    font: normal 12px Verdana, Arial, sans-serif;
}
th {text-align: left;}
body{
	font: normal 12px Verdana, Arial, sans-serif;
}
form label {
    display: inline-block;
    width: 100px;
}
form input {
    width: 400px;
}


</style>
</head>
<body bgcolor="#FFFFFF">

<?php
$searchTerms = $_REQUEST["searchterms"];
$solr = "http://localhost:8983/solr/jfk/select?q=";
$numRows = "100";
$addlParams = "&df=content&q.op=AND&fl=filename,resourcename,score,title,agency,toname,fromname,docdate&rows=$numRows";
#$addlParams = "&fl=filename,resourcename,score,title,agency,toname,fromname,docdate&rows=$numRows";
$archUrl = "https://www.archives.gov/files/research/jfk/releases/";

echo "<br>Archival search for: $searchTerms<br>";
#debug below
#var_dump($searchTerms);

#make web friendly
$searchTerms = rawurlencode($searchTerms);
$curl = $solr . "$searchTerms" . $addlParams;

#debug below
#echo "POST $curl";

$curl = curl_init($curl);
curl_setopt($curl, CURLOPT_HEADER, false);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_POST, true);
$jsonResponse = curl_exec($curl);


$jsonArray = json_decode($jsonResponse);
$totalResults = $jsonArray->{'response'}->{'numFound'};
#var_dump(json_decode($jsonResponse));
#print $jsonArray->{'responseHeader'}->{'status'};

echo "Total Results: " .  $totalResults;
if($totalResults > $numRows){echo "  Showing first $numRows.";}
echo "<br><br>";
echo "<table>";
if($totalResults > 0){echo "<tr><td><b>File Name</b></td><td><b>Doc Date</b></td><td><b>To</b></td><td><b>From</b></td><td><b>Title</b></td><td><b>Agency</b></td><td><b>Relevance</b></td></tr>";}

foreach($jsonArray->{'response'}->{'docs'} as $result){
	$pdfName = $result->{'filename'}[0];
	#echo "pdf: $pdfName";	
	$resName = $result->{'resourcename'}[0];
	#echo "res name: $resName";	
	#figure out page num from resource file	
	preg_match_all('/\d+/', $resName, $tmp);
	$pageNum = end($tmp[0]) + 1;	
	echo "<tr><td nowrap><a target=" . '"_blank"' . " href=" . '"' . $archUrl . $pdfName . '"' . ">$pdfName</a>";
	#display page numbers if greater than 1, if over 5k, it is probably one page doc	
	if($pageNum > "1" and $pageNum < "5000"){echo " (page $pageNum)";}
	echo "</td>";
	echo "<td nowrap>" . $result->{'docdate'}[0] . "</td>";	
	echo "<td>" . $result->{'toname'}[0] . "</td>";	
	echo "<td>" . $result->{'fromname'}[0] . "</td>";	
	echo "<td>" . $result->{'title'}[0] . "</td>";	
	echo "<td>" . $result->{'agency'}[0] . "</td>";	
	echo "<td>" . round($result->{'score'}, 3) . "</td>";
	echo "</tr>";
}
echo "</table>";

echo "<br><br>";
/*
foreach($jsonArray['data'] as $result) {
    echo $result['type'], '<br>';
}
*/


echo "<br><br>";

#debug below
#echo "<br><br><br>JSON Response: $jsonResponse";

#$ip = $_SERVER['REMOTE_ADDR'];
#$log = fopen('/var/www/html/af/log/qu.log', 'a');
#$today = date("D M j G:i:s T Y");
#fwrite($log, "$today - $ip - Query: $searchTerms Res: $totalResults\r\n");
#fclose($log);
?>

</body>

