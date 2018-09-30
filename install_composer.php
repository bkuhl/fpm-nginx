<?php

if (PHP_SAPI !== 'cli') {
    echo 'Warning: Composer should be invoked via the CLI version of PHP, not the '.PHP_SAPI.' SAPI'.PHP_EOL;
}

if (!function_exists('curl_version')) {
    echo 'Warning: Composer installation requires CURL'.PHP_EOL;
}

copy('https://getcomposer.org/installer', 'composer-setup.php');

$curl = curl_init('https://composer.github.io/installer.sig');
curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
$hash = trim(preg_replace('/\s+/', ' ', curl_exec($curl)));
curl_close($curl);

if (hash_file('SHA384', 'composer-setup.php') === $hash) {
    echo 'Installer verified';
} else {
    echo 'Installer corrupt: '.$hash;
    unlink('composer-setup.php');
}

echo PHP_EOL;

shell_exec('php composer-setup.php --install-dir=/usr/bin --filename=composer');

unlink('composer-setup.php');
