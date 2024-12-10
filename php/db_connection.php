<?php
$host = 'localhost';
$dbname = 'social_app';
$username = 'root';
$password = ''; // Replace with your database password

try {
     
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
