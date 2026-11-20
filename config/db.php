<?php

// Database configuration
define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
define('DB_PORT', (int) (getenv('DB_PORT') ?: 3307));
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_NAME', getenv('DB_NAME') ?: 'smart_attendance_v2');

// Application deployed at domain root
define('BASE_URL', '');

function getDB(): mysqli
{
    try {
        $conn = new mysqli(
            DB_HOST,
            DB_USER,
            DB_PASS,
            DB_NAME,
            DB_PORT
        );

        $conn->set_charset('utf8mb4');

        return $conn;

    } catch (mysqli_sql_exception $e) {

        // Log the technical error on the server
        error_log(
            'Database connection failed: ' .
            $e->getMessage()
        );

        http_response_code(500);

        exit('Database connection error.');
    }
}

$conn = getDB();
