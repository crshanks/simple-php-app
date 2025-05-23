<?php
// index.php

// Send a custom attribute to New Relic
if (extension_loaded('newrelic')) {
    echo "New Relic extension is loaded.";
    newrelic_add_custom_parameter('user_type', 'guest');
    newrelic_add_custom_parameter('app_version', '1.0-beta');
} else {
  # code...
    echo "New Relic extension is not loaded.";
}

echo "<h1>Hello from my Simple PHP App!</h1>";
echo "<p>This application is running in Docker on an M1 Mac and instrumented by New Relic.</p>";
echo "<p>Current PHP version: " . phpversion() . "</p>";

// Generate some transaction data for New Relic
if (extension_loaded('newrelic') && function_exists('newrelic_name_transaction')) {
    newrelic_name_transaction("index.php/main_page");
}

// Optional: Display phpinfo() for checking New Relic installation details.
// For security, you might want to remove this or protect it in a real application.
echo "<h2>PHP Info (includes New Relic details if loaded):</h2>";
phpinfo();
sleep(10); // make the transaction interesting enough to sample
?>
