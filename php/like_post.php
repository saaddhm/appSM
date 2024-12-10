<?php
header('Content-Type: application/json');
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $post_id = $_POST['post_id'];
    $user_id = $_POST['user_id'];

    if (empty($post_id) || empty($user_id)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input.']);
        exit();
    }

    // Check if the like already exists
    $check_query = "SELECT * FROM likes WHERE post_id = ? AND user_id = ?";
    $stmt = $conn->prepare($check_query);
    $stmt->bind_param("ii", $post_id, $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Unlike the post if already liked
        $delete_query = "DELETE FROM likes WHERE post_id = ? AND user_id = ?";
        $stmt = $conn->prepare($delete_query);
        $stmt->bind_param("ii", $post_id, $user_id);
        $stmt->execute();
        echo json_encode(['status' => 'success', 'message' => 'Post unliked.']);
    } else {
        // Like the post
        $insert_query = "INSERT INTO likes (post_id, user_id) VALUES (?, ?)";
        $stmt = $conn->prepare($insert_query);
        $stmt->bind_param("ii", $post_id, $user_id);
        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Post liked.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to like the post.']);
        }
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}
