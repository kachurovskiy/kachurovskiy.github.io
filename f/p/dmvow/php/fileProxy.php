<?php
// В PHP 4.1.0 и более ранних версиях следует использовать $HTTP_POST_FILES
// вместо $_FILES.

$uploaddir = './';
$uploadfile = $uploaddir . basename($_FILES['Filedata']['name']);

// print "<pre>";
if (move_uploaded_file($_FILES['Filedata']['tmp_name'], $uploadfile)) {
    // print "File is valid, and was successfully uploaded. ";
    // print "Here's some more debugging info:\n";
    // print_r($_FILES);
	$data = file_get_contents($uploadfile);
	echo $data;
	unlink($uploadfile);
} else {
    // print "Possible file upload attack!  Here's some debugging info:\n";
    // print "Possible file upload attack!  Дополнительная отладочная информация:\n";
    // print_r($_FILES);
}
// print "</pre>";

?>