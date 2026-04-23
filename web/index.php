<?php
$resFile = 'rested.xml';
$version = 'html';

$t = strtoupper($_GET['format']);
if ($t == "TEXT") { 
	$version = "text";
} elseif ($t == "rss") { 
	$version = "rtf";
	header("Content-type: application/rss+xml");
} elseif ($t == "PDF") {
	$version = "dompdf";
}
if ($t) {
	$version = strtolower($t);
}

$xslFile = "rested.$version.xsl";

$xp = new XsltProcessor();

$xsl = new DomDocument;
$xsl->load($xslFile);

$xp->importStylesheet($xsl);

$xml_doc = new DomDocument;
$xml_doc->load($resFile);

if ($html = $xp->transformToXML($xml_doc)) {
	if ($t == "PDF") {
		require_once("dompdf/dompdf_config.inc.php");
		$dompdf = new DOMPDF();
		$dompdf->load_html($html);
		$dompdf->render();
		$dompdf->stream("resume-cgordon.pdf");
	} else {
		echo $html;
	}
} else {
	trigger_error('XSL transformation failed.', E_USER_ERROR);
} // if


?>
