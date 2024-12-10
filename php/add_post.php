<?php
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {


// Get POST data
$user_id = $_POST['user_id'];
$content = $_POST['content'];
$image_url = $_POST['image_url'] ?? null;

if ($user_id && $content) {
    $stmt = $conn->prepare("INSERT INTO posts (user_id, content, image_url, created_at) VALUES (?, ?, ?, NOW())");
    $stmt->bind_param("iss", $user_id, $content, $image_url);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Post added successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to add post."]);
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input."]);
}

$conn->close();
}
?>

