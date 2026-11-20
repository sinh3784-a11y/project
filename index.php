
<?php

require_once __DIR__ . '/config/db.php';

session_start();

if (isset($_SESSION['admin_id'])) {
    header('Location: ' . BASE_URL . '/admin/dashboard.php');
    exit;
}

header('Location: ' . BASE_URL . '/login.php');
exit;
