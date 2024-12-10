<?php
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user['email']==$email && $user['password']==$password) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Login successful',
            'user_id' => $user['id'] // Ensure this is returned
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid email or password']);
    }
}
?>
