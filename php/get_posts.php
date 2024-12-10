<?php
include 'db_connection.php';

try {
    $stmt = $conn->prepare("SELECT posts.*, users.full_name FROM posts JOIN users ON posts.user_id = users.id ORDER BY posts.created_at DESC");
    $stmt->execute();
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['status' => 'success', 'posts' => $posts]);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
