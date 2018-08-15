#!/bin/bash

DB=$1;

mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci";

echo "La base de datos ${DB} fue creada!";