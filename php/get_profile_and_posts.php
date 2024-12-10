<?php
include 'db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

    // Validate `user_id`
    if (!$user_id) {
        echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
        exit;
    }

    try {
        // Fetch user profile
        $stmt = $conn->prepare("
            SELECT id, full_name, email, profile
            FROM users 
            WHERE id = ?
        ");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            echo json_encode(['status' => 'error', 'message' => 'User not found']);
            exit;
        }

        // Fetch posts and check if liked by the user
        $stmt = $conn->prepare("
            SELECT 
                posts.id AS post_id, 
                posts.content, 
                posts.image_url, 
                posts.created_at, 
                users.full_name, 
                users.profile,
                EXISTS (
                    SELECT 1 
                    FROM likes 
                    WHERE likes.post_id = posts.id 
                      AND likes.user_id = ?
                ) AS liked_by_user
            FROM 
                posts
            JOIN 
                users 
            ON 
                posts.user_id = users.id
            ORDER BY 
                posts.created_at DESC
        ");
        $stmt->execute([$user_id]);
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Respond with profile and posts
        echo json_encode(['status' => 'success', 'profile' => $user, 'posts' => $posts]);
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
